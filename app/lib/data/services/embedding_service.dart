import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

/// On-device embedding service using all-MiniLM-L6-v2 (TFLite).
///
/// Produces 384-dim L2-normalized vectors stored as comma-separated strings.
/// Falls back to TF-IDF cosine similarity when the model files are absent.
class EmbeddingService {
  static const _maxSeqLen = 128;
  static const _embDim = 384;

  Interpreter? _interpreter;
  Map<String, int>? _vocab;
  bool _initDone = false;
  bool _modelAvailable = false;

  // ── Initialization ──────────────────────────────────────────────────────────

  Future<void> _ensureInit() async {
    if (_initDone) return;
    _initDone = true;
    try {
      // On macOS, tflite_flutter loads its C runtime from a fixed path inside
      // the app bundle. We copy it there from Flutter assets on first launch
      // so it works regardless of how the build system ran.
      if (Platform.isMacOS) await _setupMacosDylib();

      final raw = await rootBundle.loadString('assets/models/vocab.txt');
      _vocab = {};
      var idx = 0;
      for (final line in raw.split('\n')) {
        final t = line.trim();
        if (t.isNotEmpty) _vocab![t] = idx++;
      }
      _interpreter = await Interpreter.fromAsset('assets/models/minilm.tflite');
      _modelAvailable = true;
      print('[EmbeddingService] MiniLM loaded — vocab: ${_vocab!.length} tokens');
    } catch (e, st) {
      print('[EmbeddingService] Model load failed: $e\n$st');
      _modelAvailable = false;
    }
  }

  /// Copies libtensorflowlite_c-mac.dylib from Flutter assets into the location
  /// tflite_flutter's FFI binding expects: <bundle>/Contents/resources/.
  Future<void> _setupMacosDylib() async {
    final bundleContents =
        Directory(Platform.resolvedExecutable).parent.parent.path;
    // tflite_flutter looks in Contents/resources/ (lowercase)
    final targetDir = Directory('$bundleContents/resources');
    final target = File('${targetDir.path}/libtensorflowlite_c-mac.dylib');
    if (await target.exists()) return;
    await targetDir.create(recursive: true);
    final data = await rootBundle.load(
      'assets/models/libtensorflowlite_c-mac.dylib',
    );
    await target.writeAsBytes(data.buffer.asUint8List());
    print('[EmbeddingService] Wrote TFLite dylib to ${target.path}');
  }

  bool get isModelAvailable => _modelAvailable;

  // ── Public API ──────────────────────────────────────────────────────────────

  /// Returns a 384-dim L2-normalised embedding, or [] when model isn't loaded.
  Future<List<double>> embed(String text) async {
    await _ensureInit();
    if (!_modelAvailable || text.trim().isEmpty) return [];
    try {
      final result = _runInference(text);
      print('[EmbeddingService] Embedded ${text.length} chars → ${result.length} dims');
      return result;
    } catch (e, st) {
      print('[EmbeddingService] Inference failed: $e\n$st');
      return [];
    }
  }

  /// Splits [text] into overlapping 320-char chunks, embeds each locally,
  /// then returns a single averaged + re-normalised 384-dim vector.
  Future<List<double>> embedChunked(String text) async {
    const chunkSize = 320;
    const stride = 240; // 75% overlap

    final chunks = <String>[];
    if (text.length <= chunkSize) {
      chunks.add(text);
    } else {
      int start = 0;
      while (start < text.length) {
        final end = min(start + chunkSize, text.length);
        chunks.add(text.substring(start, end));
        start += stride;
      }
    }

    final vectors = <List<double>>[];
    for (final chunk in chunks) {
      final vec = await embed(chunk);
      if (vec.isNotEmpty) vectors.add(vec);
    }

    if (vectors.isEmpty) return [];
    if (vectors.length == 1) return vectors.first;

    // Element-wise average
    final avg = List<double>.filled(_embDim, 0.0);
    for (final v in vectors) {
      for (int i = 0; i < _embDim; i++) { avg[i] += v[i]; }
    }
    for (int i = 0; i < _embDim; i++) { avg[i] /= vectors.length; }

    // Re-normalise (averaging breaks L2 norm)
    final norm = sqrt(avg.fold(0.0, (s, x) => s + x * x));
    if (norm == 0) return avg;
    return [for (final x in avg) x / norm];
  }

  double cosineSimilarity(List<double> a, List<double> b) {
    if (a.isEmpty || b.isEmpty || a.length != b.length) return 0.0;
    double dot = 0, na = 0, nb = 0;
    for (int i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      na += a[i] * a[i];
      nb += b[i] * b[i];
    }
    if (na == 0 || nb == 0) return 0.0;
    return dot / (sqrt(na) * sqrt(nb));
  }

  // ── MiniLM Inference ────────────────────────────────────────────────────────

  List<double> _runInference(String text) {
    final interp = _interpreter!;

    final tokens = _bertTokenize(text);
    final seqLen = min(tokens.length, _maxSeqLen);
    final inputIds = [List<int>.filled(seqLen, 0)];
    final attnMask = [List<int>.filled(seqLen, 0)];

    for (int i = 0; i < seqLen; i++) {
      inputIds[0][i] = tokens[i];
      attnMask[0][i] = 1;
    }

    // Resize dynamic input tensors and reallocate before writing data.
    // Tensor index 0 is named "inputs_1" (attention_mask) and index 1 is
    // "inputs" (input_ids) for this MiniLM SavedModel export.
    interp.resizeInputTensor(0, [1, seqLen]);
    interp.resizeInputTensor(1, [1, seqLen]);
    interp.allocateTensors();

    // Fetch tensors AFTER allocateTensors() — prior references become stale
    // after reallocation and their data pointers are invalid (FFI crash).
    final inputTensors = interp.getInputTensors();
    final outputTensors = interp.getOutputTensors();

    print('[EmbeddingService] inputs=${inputTensors.length} outputs=${outputTensors.length}');
    for (int i = 0; i < inputTensors.length; i++) {
      final t = inputTensors[i];
      print('  in[$i] name=${t.name} shape=${t.shape} type=${t.type}');
    }
    for (int i = 0; i < outputTensors.length; i++) {
      final t = outputTensors[i];
      print('  out[$i] name=${t.name} shape=${t.shape} type=${t.type}');
    }

    inputTensors[0].setTo(attnMask);
    if (inputTensors.length > 1) inputTensors[1].setTo(inputIds);

    interp.invoke();

    // Read first output tensor — shape [1, seqLen, 384] or [1, 384]
    final outTensor = outputTensors[0];
    final rawData = outTensor.data.buffer.asFloat32List();
    print('[EmbeddingService] raw output length=${rawData.length}');

    if (outTensor.shape.length == 2) {
      // Shape [1, 384] — already pooled
      return _normalize(rawData.sublist(0, _embDim).map((v) => v.toDouble()).toList());
    } else {
      // Shape [1, seqLen, 384] — mean-pool over non-padding tokens
      final seqLen = outTensor.shape[1]; // actual dynamic seqLen
      final embeddings = <List<double>>[];
      for (int i = 0; i < seqLen; i++) {
        embeddings.add(
          rawData.sublist(i * _embDim, (i + 1) * _embDim).map((v) => v.toDouble()).toList(),
        );
      }
      return _normalize(_meanPool(embeddings, attnMask[0]));
    }
  }

  List<double> _meanPool(List<List<double>> tokenEmbs, List<int> mask) {
    final result = List<double>.filled(_embDim, 0.0);
    int count = 0;
    for (int i = 0; i < mask.length; i++) {
      if (mask[i] == 1) {
        for (int j = 0; j < _embDim; j++) result[j] += tokenEmbs[i][j];
        count++;
      }
    }
    if (count > 0) {
      for (int j = 0; j < _embDim; j++) result[j] /= count;
    }
    return result;
  }

  List<double> _normalize(List<double> v) {
    double norm = 0;
    for (final x in v) norm += x * x;
    norm = sqrt(norm);
    if (norm == 0) return v;
    return [for (final x in v) x / norm];
  }

  // ── BERT WordPiece Tokenizer ────────────────────────────────────────────────

  List<int> _bertTokenize(String text) {
    final vocab = _vocab!;
    final clsId = vocab['[CLS]'] ?? 101;
    final sepId = vocab['[SEP]'] ?? 102;
    final unkId = vocab['[UNK]'] ?? 100;

    final ids = <int>[clsId];
    for (final word in _basicTokenize(text)) {
      for (final id in _wordpiece(word, vocab, unkId)) {
        ids.add(id);
        if (ids.length >= _maxSeqLen - 1) break;
      }
      if (ids.length >= _maxSeqLen - 1) break;
    }
    ids.add(sepId);
    return ids;
  }

  List<String> _basicTokenize(String text) {
    final s = text.toLowerCase().replaceAll(RegExp(r"[^\w\s]"), ' ');
    return s.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  }

  List<int> _wordpiece(String word, Map<String, int> vocab, int unkId) {
    if (word.isEmpty) return [];
    if (word.length > 200) return [unkId];
    if (vocab.containsKey(word)) return [vocab[word]!];

    final result = <int>[];
    int start = 0;
    while (start < word.length) {
      int end = word.length;
      int? foundId;
      while (start < end) {
        final sub = (start == 0 ? '' : '##') + word.substring(start, end);
        if (vocab.containsKey(sub)) {
          foundId = vocab[sub];
          break;
        }
        end--;
      }
      if (foundId == null) return [unkId];
      result.add(foundId);
      start = end;
    }
    return result;
  }

  // ── TF-IDF (fallback when model not loaded) ─────────────────────────────────

  List<double> rankAgainst(List<String> posts, String query) {
    if (posts.isEmpty) return [];
    final tokenized = [...posts.map(_tfidfTokenize), _tfidfTokenize(query)];
    final n = tokenized.length;
    final df = <String, int>{};
    for (final doc in tokenized) {
      for (final t in doc.toSet()) {
        df[t] = (df[t] ?? 0) + 1;
      }
    }

    Map<String, double> vec(List<String> tokens) {
      if (tokens.isEmpty) return {};
      final tf = <String, int>{};
      for (final t in tokens) tf[t] = (tf[t] ?? 0) + 1;
      return {
        for (final e in tf.entries)
          e.key: (1 + log(e.value)) * (log((n + 1) / ((df[e.key] ?? 0) + 1)) + 1),
      };
    }

    final qVec = vec(tokenized.last);
    if (qVec.isEmpty) return List.filled(posts.length, 0.0);
    return [for (int i = 0; i < posts.length; i++) _cosineSparse(vec(tokenized[i]), qVec)];
  }

  List<String> _tfidfTokenize(String text) {
    const stop = {
      'a', 'an', 'the', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for',
      'of', 'with', 'by', 'is', 'are', 'was', 'be', 'have', 'has', 'do',
      'will', 'can', 'i', 'you', 'we', 'they', 'this', 'that', 'my', 'our',
      'what', 'how', 'not', 'so', 'as', 'if', 'just', 'also', 'more',
    };
    final s = text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ');
    return s.split(' ').where((t) => t.length > 1 && !stop.contains(t)).toList();
  }

  double _cosineSparse(Map<String, double> a, Map<String, double> b) {
    if (a.isEmpty || b.isEmpty) return 0.0;
    double dot = 0, na = 0, nb = 0;
    for (final e in a.entries) {
      dot += e.value * (b[e.key] ?? 0.0);
      na += e.value * e.value;
    }
    for (final v in b.values) nb += v * v;
    if (na == 0 || nb == 0) return 0.0;
    return dot / (sqrt(na) * sqrt(nb));
  }
}
