import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── 골드 / 강조 ──
  static const Color gold = Color(0xFFF3C55B);
  static const Color goldBorder = Color(0x66C39A39);
  static const Color goldCta = Color(0xFFF0A618);
  static const Color goldAction = Color(0xFFF0A21F);
  static const Color goldCoin = Color(0xFFF4CC54);
  static const Color goldBonus = Color(0xFFFFC145);
  static const Color goldAmber = Color(0xFFF0A941);

  // ── 빨강 / 코랄 ──
  static const Color redAction = Color(0xFFE4554C);
  static const Color coral = Color(0xFFFF6B5C);
  static const Color coralAlt = Color(0xFFFF6B61);
  static const Color coralGradientEnd = Color(0xFFFF5B4F);
  static const Color coralWarm = Color(0xFFFF7860);
  static const Color coralDeep = Color(0xFFFF7750);

  // ── 블루 ──
  static const Color blueAccent = Color(0xFF1E9AFF);
  static const Color blueButton = Color(0xFF1A9CFF);
  static const Color blueChips = Color(0xFF35A1FF);
  static const Color blueHand = Color(0xFF39A1FF);

  // ── 퍼플 ──
  static const Color purpleDiscard = Color(0xFF8E5BD9);

  // ── 블라인드 뱃지 ──
  static const Color blindSmall = Color(0xFF4258D6);
  static const Color blindBig = Color(0xFFC78B18);
  static const Color blindBoss = Color(0xFF7E2F9A);

  // ── 테이블 배경 ──
  static const Color tableGreen1 = Color(0xFF153A35);
  static const Color tableGreen2 = Color(0xFF1F5C4F);
  static const Color tableGreen3 = Color(0xFF102A24);

  // ── 패널 배경 ──
  static const Color panelDark = Color(0xFF1E2626);
  static const Color panelDeep = Color(0xFF181F24);
  static const Color panelInfo = Color(0xFF10161C);
  static const Color modalBg = Color(0xF010233A);
  static const Color scrimBg = Color(0xCC08111F);

  // ── 점수 연출 ──
  static const Color scoreFinal = Color(0xFFFFF17C);

  // ── 타일 색상 (TileColor) ──
  static const Color tileRed = Color(0xFFD74452);
  static const Color tileBlue = Color(0xFF233E9A);
  static const Color tileYellow = Color(0xFFE07A26);
  static const Color tileBlack = Color(0xFF193A2B);

  // ── 타일 카드 ──
  static const Color tileFaceTop = Color(0xFFFFFEFB);
  static const Color tileFaceBottom = Color(0xFFF1E8D7);
  static const Color tileBorderLifted = Color(0xFFF2C14E);
  static const Color tileBorderNormal = Color(0xFFD8C4A0);

  // ── Jester 바 ──
  static const Color jesterFilledTop = Color(0xFFF3E6B8);
  static const Color jesterFilledBottom = Color(0xFFC9994A);
  static const Color jesterFilledBorder = Color(0xFFFFF0C5);
  static const Color jesterEmptyTop = Color(0xFF25453F);
  static const Color jesterEmptyBottom = Color(0xFF1B312C);
  static const Color jesterExtendedTop = Color(0xFF21312E);
  static const Color jesterExtendedBottom = Color(0xFF172322);
  static const Color jesterTextDark = Color(0xFF5F3C0C);
  static const Color jesterTextBody = Color(0xFF2E2A20);
  static const Color jesterTextName = Color(0xFF2A2519);

  // ── 중앙 패널 ──
  static const Color centerPanelBg = Color(0x552C7A66);
  static const Color centerPanelBorder = Color(0x55D8C27A);

  // ── 메타 행 ──
  static const Color metaRowBorder = Color(0x44FFFFFF);

  // ── 모달 보조 ──
  static const Color mintButton = Color(0xFF63E6BE);
  static const Color tabInactive = Color(0xFF3C434A);
  static const Color guideRowBg = Color(0xFFE8EEF8);
  static const Color guideRowText = Color(0xFF2C3340);
  static const Color gradientBlue = Color(0xFF2196F3);
  static const Color gameOverBg = Color(0xF0331120);
  static const Color runCompleteBg = Color(0xF0102C20);

  // ── 타이틀 화면 ──
  static const Color titleGold = Color(0xFFFFD54F);
  static const Color titleOrange = Color(0xFFE65100);
  static const Color titleBlue = Color(0xFF3CAEE0);
  static const Color titlePurple = Color(0xFF7E57C2);
  static const Color titleDropdown = Color(0xFF1A1A3E);
  static const Color titleStarCyan = Color(0xFFAADDFF);
  static const Color titleStarYellow = Color(0xFFFFEEAA);
  static const Color titleStarPink = Color(0xFFFFAAAA);
  static const Color titleBgDark = Color(0xFF05051A);
  static const Color titleBgMid = Color(0xFF0A0A2E);
  static const Color titleBgLight = Color(0xFF12123A);

  // ── 디버그 ──
  static const Color debugLockTint = Color(0x30FF4444);
  static const Color lockTransparent = Color(0x01000000);
}

abstract final class BattleSpacing {
  static const double frameRadius = 24.0;
  static const double cardRadius = 14.0;
  static const double panelRadius = 22.0;
  static const double badgeRadius = 12.0;
  static const double tileRadius = 10.0;
  static const double modalRadius = 20.0;

  static const double designWidth = 390.0;
  static const double designHeight = 844.0;
  static const double targetAspectRatio = designWidth / designHeight;

  static double compactGap(bool compact) => compact ? 6.0 : 8.0;
  static double tinyGap(bool compact) => compact ? 4.0 : 6.0;

  static const double handHeightCompact = 190.0;
  static const double handHeightNormal = 210.0;
  static const double actionHeightCompact = 34.0;
  static const double actionHeightNormal = 40.0;
  static const double topBandHeightCompact = 154.0;
  static const double topBandHeightNormal = 164.0;

}

abstract final class HandAnimationDurations {
  static const Duration drawFlight = Duration(milliseconds: 340);
  static const Duration drawStagger = Duration(milliseconds: 55);
  static const Duration flightSettle = Duration(milliseconds: 40);
}
