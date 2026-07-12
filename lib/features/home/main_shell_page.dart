import 'package:flutter/material.dart';

import '../../app/app_form_styles.dart';
import '../../config/project_config.dart';
import '../dashboard/dashboard_page.dart';
import '../signals/signals_page.dart';
import '../broadcast/broadcast_page.dart';
import '../signals/campaign_model.dart';
import '../signals/signal_service.dart';
import 'package:dio/dio.dart';

class MainShellPage extends StatefulWidget {
  final ProjectConfig project;
  final String? adminUsername;
  final int? adminTelegramUserId;
  final String? adminRole;

  const MainShellPage({
    super.key,
    required this.project,
    required this.adminUsername,
    required this.adminTelegramUserId,
    required this.adminRole,
  });

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _selectedIndex = 0;

  late final List<_ShellTab> _tabs = [
    _ShellTab(
      label: 'Dashboard',
      icon: Icons.dashboard_rounded,
      page: DashboardPage(project: widget.project),
    ),
    _ShellTab(
      label: 'Signals',
      icon: Icons.campaign_rounded,
      page: SignalsPage(
        adminUsername: widget.adminUsername,
        adminRole: widget.adminRole,
        showHeader: false,
        showBroadcast: false,
      ),
    ),
    _ShellTab(
      label: 'Broadcast',
      icon: Icons.mark_email_read_rounded,
      page: _BroadcastTabPage(
        adminUsername: widget.adminUsername,
        adminTelegramUserId: widget.adminTelegramUserId,
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 820;

    return Scaffold(
      backgroundColor: appSheetBackgroundColor(context),
      body: SafeArea(
        child: Row(
          children: [
            if (isWide)
              _SideNavigation(
                tabs: _tabs,
                selectedIndex: _selectedIndex,
                onSelected: _selectTab,
                adminUsername: widget.adminUsername,
                adminRole: widget.adminRole,
                project: widget.project,
              ),
            Expanded(
              child: _tabs[_selectedIndex].page,
            ),
          ],
        ),
      ),
      bottomNavigationBar: isWide
          ? null
          : _BottomNavigation(
              tabs: _tabs,
              selectedIndex: _selectedIndex,
              onSelected: _selectTab,
              project: widget.project,
            ),
    );
  }

  void _selectTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

class _ShellTab {
  final String label;
  final IconData icon;
  final Widget page;

  const _ShellTab({
    required this.label,
    required this.icon,
    required this.page,
  });
}

class _SideNavigation extends StatelessWidget {
  final List<_ShellTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final String? adminUsername;
  final String? adminRole;
  final ProjectConfig project;

  const _SideNavigation({
    required this.tabs,
    required this.selectedIndex,
    required this.onSelected,
    required this.adminUsername,
    required this.adminRole,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    final username =
        adminUsername?.trim().isNotEmpty == true ? adminUsername! : 'Admin';

    final role = adminRole?.trim().isNotEmpty == true ? adminRole! : 'admin';

    return Container(
      width: 280,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: appIsDarkMode(context)
            ? project.cardDarkColor
            : appCardBackgroundColor(context),
        border: Border(
          right: BorderSide(
            color: appBorderColor(context),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BrandHeader(
            username: username,
            role: role,
            project: project,
          ),
          const SizedBox(height: 24),
          for (int i = 0; i < tabs.length; i++)
            _SideNavItem(
              tab: tabs[i],
              selected: selectedIndex == i,
              onTap: () => onSelected(i),
              primaryColor: project.primaryColor,
            ),
          const Spacer(),
          Text(
            project.dashboardSubtitle,
            style: TextStyle(
              color: appSecondaryTextColor(context),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  final String username;
  final String role;
  final ProjectConfig project;

  const _BrandHeader({
    required this.username,
    required this.role,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 54,
          width: 54,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                project.primaryColor,
                project.secondaryColor,
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: project.primaryColor.withValues(alpha: 0.25),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.auto_graph_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                project.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: appPrimaryTextColor(context),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '@$username • ${role.toUpperCase()}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: appSecondaryTextColor(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SideNavItem extends StatelessWidget {
  final _ShellTab tab;
  final bool selected;
  final VoidCallback onTap;
  final Color primaryColor;

  const _SideNavItem({
    required this.tab,
    required this.selected,
    required this.onTap,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final selectedBg = primaryColor.withValues(
      alpha: appIsDarkMode(context) ? 0.22 : 0.12,
    );

    final selectedColor = appIsDarkMode(context) ? Colors.white : primaryColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
          decoration: BoxDecoration(
            color: selected ? selectedBg : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                tab.icon,
                color: selected ? selectedColor : appSecondaryTextColor(context),
                size: 22,
              ),
              const SizedBox(width: 12),
              Text(
                tab.label,
                style: TextStyle(
                  color:
                      selected ? selectedColor : appSecondaryTextColor(context),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  final List<_ShellTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final ProjectConfig project;

  const _BottomNavigation({
    required this.tabs,
    required this.selectedIndex,
    required this.onSelected,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 98,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 14),
      decoration: BoxDecoration(
        color: project.cardDarkColor,
        border: const Border(
          top: BorderSide(
            color: Color(0xFF1F2937),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (int i = 0; i < tabs.length; i++)
            _BottomNavItem(
              icon: tabs[i].icon,
              label: tabs[i].label,
              selected: selectedIndex == i,
              onTap: () => onSelected(i),
              primaryColor: project.primaryColor,
              secondaryColor: project.secondaryColor,
            ),
        ],
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color primaryColor;
  final Color secondaryColor;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = selected ? Colors.white : const Color(0xFFCBD5E1);
    final textColor = selected ? Colors.white : const Color(0xFFCBD5E1);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        width: 112,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              width: selected ? 82 : 76,
              height: 40,
              decoration: BoxDecoration(
                gradient: selected
                    ? LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          primaryColor,
                          secondaryColor,
                        ],
                      )
                    : null,
                color: selected
                    ? null
                    : const Color(0xFF1F2937).withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(999),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.32),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 27,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                letterSpacing: 0.2,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BroadcastTabPage extends StatefulWidget {
  final String? adminUsername;
  final int? adminTelegramUserId;

  const _BroadcastTabPage({
    required this.adminUsername,
    required this.adminTelegramUserId,
  });

  @override
  State<_BroadcastTabPage> createState() => _BroadcastTabPageState();
}

class _BroadcastTabPageState extends State<_BroadcastTabPage> {
  late final SignalService _service;
  late Future<List<CampaignModel>> _futureCampaigns;

  @override
  void initState() {
    super.initState();
    _service = SignalService(Dio());
    _futureCampaigns = _service.fetchCampaigns();
  }

  Future<void> _refresh() async {
    setState(() {
      _futureCampaigns = _service.fetchCampaigns();
    });

    await _futureCampaigns;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appSheetBackgroundColor(context),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.all(24),
            physics: const AlwaysScrollableScrollPhysics(
              parent: ClampingScrollPhysics(),
            ),
            children: [
              Text(
                'Broadcast Center',
                style: TextStyle(
                  color: appPrimaryTextColor(context),
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Create, schedule, and review marketing/follow-up broadcasts.',
                style: TextStyle(
                  color: appSecondaryTextColor(context),
                  fontSize: 14,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 20),
              FutureBuilder<List<CampaignModel>>(
                future: _futureCampaigns,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      height: 180,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: appCardBackgroundColor(context),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: appBorderColor(context),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Failed to load campaigns for broadcast.',
                            style: TextStyle(
                              color: Color(0xFFDC2626),
                              fontWeight: FontWeight.w800,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _refresh,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  return BroadcastPage(
                    campaigns: snapshot.data ?? [],
                    adminUsername: widget.adminUsername,
                    adminTelegramUserId: widget.adminTelegramUserId,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
