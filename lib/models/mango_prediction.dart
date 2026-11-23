import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class MangoStageProfile {
  final String label;
  final String titleBn;
  final String grade;
  final String shelfLife;
  final String storageAdvice;
  final String consumptionNote;
  final Color color;
  final IconData icon;

  const MangoStageProfile({
    required this.label,
    required this.titleBn,
    required this.grade,
    required this.shelfLife,
    required this.storageAdvice,
    required this.consumptionNote,
    required this.color,
    required this.icon,
  });
}

class MangoPrediction {
  final String imagePath;
  final String label;
  final double confidence;
  final Map<String, double> probabilities;
  final int inferenceTimeMs;
  final DateTime timestamp;

  const MangoPrediction({
    required this.imagePath,
    required this.label,
    required this.confidence,
    required this.probabilities,
    required this.inferenceTimeMs,
    required this.timestamp,
  });

  MangoStageProfile get profile => MangoStageRegistry.getProfile(label);
}

class MangoStageRegistry {
  MangoStageRegistry._();

  static const Map<String, MangoStageProfile> profiles = {
    'Fully Ripe': MangoStageProfile(
      label: 'Fully Ripe',
      titleBn: 'সম্পূর্ণ পাকা',
      grade: 'Grade A • Prime',
      shelfLife: '২–৪ দিন',
      storageAdvice: '১০–১২°C তাপমাত্রায় ফ্রিজে সংরক্ষণ করলে সতেজতা বজায় থাকবে।',
      consumptionNote: 'তাৎক্ষণিক খাওয়া ও খুচরা বিক্রয়ের জন্য সেরা পর্যায়।',
      color: AppColors.fullyRipe,
      icon: Icons.verified_rounded,
    ),
    'Semi Ripe': MangoStageProfile(
      label: 'Semi Ripe',
      titleBn: 'আধাপাকা',
      grade: 'Grade A • Transit Ready',
      shelfLife: '৪–৭ দিন',
      storageAdvice: 'স্বাভাবিক কক্ষ তাপমাত্রায় (২২–২৫°C) বায়ু চলাচলযুক্ত স্থানে রাখুন।',
      consumptionNote: 'দূরপাল্লার পরিবহন ও ২–৩ দিন পর বিক্রয়ের জন্য আদর্শ।',
      color: AppColors.semiRipe,
      icon: Icons.schedule_rounded,
    ),
    'Unripe': MangoStageProfile(
      label: 'Unripe',
      titleBn: 'কাঁচা আম',
      grade: 'Grade A • Long Shelf-Life',
      shelfLife: '৮–১৪ দিন',
      storageAdvice: 'শুকনো ও ছায়াযুক্ত স্থানে রাখুন; এখনই ফ্রিজে রাখবেন না।',
      consumptionNote: 'রপ্তানি, দীর্ঘ সংরক্ষণ বা আচার/চাটনির জন্য উপযোগী।',
      color: AppColors.unripe,
      icon: Icons.eco_rounded,
    ),
    'Over Ripe': MangoStageProfile(
      label: 'Over Ripe',
      titleBn: 'অতিরিক্ত পাকা',
      grade: 'Grade B • Immediate Use',
      shelfLife: '১২–২৪ ঘণ্টা',
      storageAdvice: 'অবিলম্বে ৪–৮°C তাপমাত্রায় রাখুন অথবা প্রক্রিয়াজাত করুন।',
      consumptionNote: 'জুস, পাল্প বা স্মুদি তৈরিতে দ্রুত ব্যবহার করুন।',
      color: AppColors.overRipe,
      icon: Icons.warning_amber_rounded,
    ),
    'Rotten': MangoStageProfile(
      label: 'Rotten',
      titleBn: 'নষ্ট / পচা',
      grade: 'Rejected • Unsafe',
      shelfLife: '০ দিন (অনুপযোগী)',
      storageAdvice: 'ভালো আমের সংস্পর্শ থেকে দ্রুত আলাদা করে অপসারণ করুন।',
      consumptionNote: 'খাওয়া বা বাজারজাত করার জন্য সম্পূর্ণ অনুপযোগী।',
      color: AppColors.rotten,
      icon: Icons.dangerous_rounded,
    ),
  };

  static MangoStageProfile getProfile(String label) {
    return profiles[label] ?? profiles['Fully Ripe']!;
  }
}
