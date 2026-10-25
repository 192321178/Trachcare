import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trachcare/components/ui_kit.dart';
import 'package:trachcare/style/design_system.dart';

class Information extends StatelessWidget {
  const Information({super.key});

  static const _sections = <({String title, String body, IconData icon})>[
    (
      title: 'What is a tracheostomy?',
      icon: Icons.medical_information_rounded,
      body: 'Tracheostomy is a surgical procedure that creates an airway through '
          'the neck, often needed after respiratory failure, trauma, or prolonged '
          'intubation. After the operation, patients need careful daily airway '
          'management to prevent complications and protect quality of life — and '
          'doing that well at home is genuinely hard for patients and caregivers.',
    ),
    (
      title: 'Mobile health in tracheostomy care',
      icon: Icons.phone_android_rounded,
      body: 'Mobile health applications offer a practical way to close that gap. '
          'TrachCare was built to support patients and caregivers at home with a '
          'comprehensive set of features that replace guesswork with guided routine.',
    ),
    (
      title: 'What TrachCare includes',
      icon: Icons.play_circle_outline_rounded,
      body: 'Informative videos that teach essential tasks such as cleaning the '
          'inner tube, changing tracheostomy ties, performing daily cleaning and '
          'dressing around the tube site, and proper suctioning technique — plus '
          'spigotting check-ins and daily vitals your doctor can review.',
    ),
    (
      title: 'Empowering patients and caregivers',
      icon: Icons.volunteer_activism_rounded,
      body: 'By using mobile technology, TrachCare aims to give patients and '
          'caregivers the knowledge, tools and support needed to navigate the '
          'complexities of tracheostomy care with confidence.',
    ),
    (
      title: 'Research and evaluation',
      icon: Icons.science_rounded,
      body: 'This project documents the rationale behind the application and its '
          'potential to improve life for post-operative tracheostomy patients. '
          'Through evaluation of effectiveness and user experience, the study '
          'assesses how a purpose-built mobile app changes home tracheostomy care '
          'and patient outcomes, contributing to the growing evidence for mobile '
          'health in airway management.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 190,
            backgroundColor: AppColors.teal,
            leading: TcIconButton(
              icon: Icons.arrow_back_rounded,
              color: Colors.white,
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: const FlexibleSpaceBar(
              background: _AboutHero(),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.xxl,
                AppSpacing.page, AppSpacing.xxxl),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _AboutSection(section: _sections[index]),
                ),
                childCount: _sections.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutHero extends StatelessWidget {
  const _AboutHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.page, AppSpacing.md, AppSpacing.page, AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child:
                        Image.asset('assets/images/0.png', fit: BoxFit.cover),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About TrachCare',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Home tracheostomy care, guided',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection({required this.section});

  final ({String title, String body, IconData icon}) section;

  @override
  Widget build(BuildContext context) {
    return TcCard(
      padding: EdgeInsets.zero,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
          childrenPadding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.mintSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(section.icon, size: 19, color: AppColors.teal),
          ),
          title: Text(section.title,
              style: Theme.of(context).textTheme.titleSmall),
          iconColor: AppColors.teal,
          collapsedIconColor: AppColors.inkMuted,
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                section.body,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.inkBody, height: 1.55),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
