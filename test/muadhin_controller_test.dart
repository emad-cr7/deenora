import 'package:deenora/core/widget/error/error_screen.dart';
import 'package:deenora/features/settings/muadhin/controllers/muadhin_controller.dart';
import 'package:deenora/features/settings/muadhin/controllers/muadhin_player_controller.dart';
import 'package:deenora/features/settings/muadhin/models/muadhin_audio_model.dart';
import 'package:deenora/features/settings/muadhin/models/muadhin_model.dart';
import 'package:deenora/features/settings/muadhin/models/muadhin_type.dart';
import 'package:deenora/features/settings/muadhin/repository/muadhin_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeMuadhinRepository extends MuadhinRepository {
  final List<MuadhinModel> sampleMuadhins;
  final bool shouldFail;

  FakeMuadhinRepository({
    required this.sampleMuadhins,
    this.shouldFail = false,
  });

  @override
  Future<List<MuadhinModel>> getMuadhins({bool forceRefresh = false}) async {
    if (shouldFail) {
      throw Exception('Network connection error');
    }
    return sampleMuadhins;
  }
}

class FakeMuadhinPlayerController extends MuadhinPlayerController {
  String? playedUrl;
  String? playedId;
  MuadhinType? playedType;
  bool isStopped = false;
  bool isPaused = false;

  @override
  Future<void> playMuadhin({
    required String audioUrl,
    required String muadhinId,
    required MuadhinType type,
  }) async {
    playedUrl = audioUrl;
    playedId = muadhinId;
    playedType = type;
    isStopped = false;
    isPaused = false;
    notifyListeners();
  }

  @override
  Future<void> pause() async {
    isPaused = true;
    notifyListeners();
  }

  @override
  Future<void> stop() async {
    isStopped = true;
    playedId = null;
    notifyListeners();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final sampleMuadhin1 = MuadhinModel(
    id: 'm1',
    nameAr: 'الشيخ الأول',
    categoryAr: 'مؤذن',
    isMosque: false,
    locationAr: 'مكة',
    imageUrl: 'https://example.com/1.jpg',
    adhan: const MuadhinAudioModel(
      isAvailable: true,
      audioUrl: 'https://example.com/adhan1.mp3',
      apiUrl: 'https://example.com/api/adhan/1',
    ),
    iqama: const MuadhinAudioModel(
      isAvailable: true,
      audioUrl: 'https://example.com/iqama1.mp3',
      apiUrl: 'https://example.com/api/iqama/1',
    ),
  );

  final sampleMuadhin2 = MuadhinModel(
    id: 'm2',
    nameAr: 'الشيخ الثاني',
    categoryAr: 'قارئ',
    isMosque: false,
    locationAr: 'الرياض',
    imageUrl: 'https://example.com/2.jpg',
    adhan: const MuadhinAudioModel(
      isAvailable: true,
      audioUrl: 'https://example.com/adhan2.mp3',
      apiUrl: 'https://example.com/api/adhan/2',
    ),
    iqama: const MuadhinAudioModel(
      isAvailable: false,
      audioUrl: null,
      apiUrl: 'https://example.com/api/iqama/2',
    ),
  );

  group('MuadhinController State Tests', () {
    test('initial state has default adhan type and is not loading', () {
      final repo = FakeMuadhinRepository(
        sampleMuadhins: [sampleMuadhin1, sampleMuadhin2],
      );
      final controller = MuadhinController(repository: repo);

      expect(controller.selectedType, MuadhinType.adhan);
      expect(controller.isLoading, isFalse);
      expect(controller.hasError, isFalse);
      expect(controller.expandedMuadhinId, isNull);
    });

    test('loadMuadhins successfully populates data and filters correctly', () async {
      final repo = FakeMuadhinRepository(
        sampleMuadhins: [sampleMuadhin1, sampleMuadhin2],
      );
      final controller = MuadhinController(repository: repo);

      await controller.loadMuadhins();

      expect(controller.isLoading, isFalse);
      expect(controller.hasError, isFalse);
      expect(controller.allMuadhins.length, 2);

      expect(controller.currentMuadhins.length, 2);

      controller.switchType(MuadhinType.iqama);
      expect(controller.selectedType, MuadhinType.iqama);
      expect(controller.currentMuadhins.length, 1);
      expect(controller.currentMuadhins.first.id, 'm1');
    });

    test('switchType stops playing audio and collapses card', () async {
      final fakePlayer = FakeMuadhinPlayerController();
      final repo = FakeMuadhinRepository(
        sampleMuadhins: [sampleMuadhin1, sampleMuadhin2],
      );
      final controller = MuadhinController(
        repository: repo,
        playerController: fakePlayer,
      );

      await controller.loadMuadhins();
      await controller.toggleExpand(sampleMuadhin1);

      expect(controller.expandedMuadhinId, 'm1');
      expect(fakePlayer.playedId, 'm1');

      controller.switchType(MuadhinType.iqama);

      expect(controller.selectedType, MuadhinType.iqama);
      expect(controller.expandedMuadhinId, isNull);
      expect(fakePlayer.isStopped, isTrue);
    });

    test('toggleExpand auto-plays audio on expand and pauses on collapse', () async {
      final fakePlayer = FakeMuadhinPlayerController();
      final repo = FakeMuadhinRepository(
        sampleMuadhins: [sampleMuadhin1, sampleMuadhin2],
      );
      final controller = MuadhinController(
        repository: repo,
        playerController: fakePlayer,
      );

      await controller.loadMuadhins();

      await controller.toggleExpand(sampleMuadhin1);
      expect(controller.isExpanded('m1'), isTrue);
      expect(fakePlayer.playedId, 'm1');
      expect(fakePlayer.playedUrl, 'https://example.com/adhan1.mp3');

      await controller.toggleExpand(sampleMuadhin1);
      expect(controller.isExpanded('m1'), isFalse);
      expect(fakePlayer.isPaused, isTrue);
    });

    test('handles failure and classifies error appropriately', () async {
      final repo = FakeMuadhinRepository(
        sampleMuadhins: [],
        shouldFail: true,
      );
      final controller = MuadhinController(repository: repo);

      await controller.loadMuadhins();

      expect(controller.hasError, isTrue);
      expect(controller.errorType, AppErrorType.noInternet);
    });
  });
}
