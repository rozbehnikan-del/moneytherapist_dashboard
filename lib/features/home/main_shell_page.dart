import 'package:flutter/material.dart';

import '../../app/app_form_styles.dart';
import '../dashboard/dashboard_page.dart';
import '../signals/signals_page.dart';
import '../broadcast/broadcast_page.dart';
import '../signals/campaign_model.dart';
import '../signals/signal_service.dart';
import 'package:dio/dio.dart';

class MainShellPage extends StatefulWidget {
  final String? adminUsername;
  final String? adminRole;

  const MainShellPage({
    super.key,
    required this.adminUsername,
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
      page: const DashboardPage(),
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

  const _SideNavigation({
    required this.tabs,
    required this.selectedIndex,
    required this.onSelected,
    required this.adminUsername,
    required this.adminRole,
  });

  @override
  Widget build(BuildContext context) {
    final username =
        adminUsername?.trim().isNotEmpty == true ? adminUsername! : 'Admin';

    final role = adminRole?.trim().isNotEmpty == true ? adminRole! : 'admin';

    return Container(
      width: 260,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: appCardBackgroundColor(context),
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
          ),
          const SizedBox(height: 24),
          for (int i = 0; i < tabs.length; i++)
            _SideNavItem(
              tab: tabs[i],
              selected: selectedIndex == i,
              onTap: () => onSelected(i),
            ),
          const Spacer(),
          Text(
            'Money Therapist Expert System',
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

  const _BrandHeader({
    required this.username,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 46,
          width: 46,
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.insights_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Money Therapist',
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

  const _SideNavItem({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selectedBg = appIsDarkMode(context)
        ? const Color(0xFF1E3A8A)
        : const Color(0xFFEFF6FF);

    final selectedColor =
        appIsDarkMode(context) ? Colors.white : const Color(0xFF2563EB);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
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

  const _BottomNavigation({
    required this.tabs,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onSelected,
      backgroundColor: appCardBackgroundColor(context),
      indicatorColor: appIsDarkMode(context)
          ? const Color(0xFF1E3A8A)
          : const Color(0xFFEFF6FF),
      destinations: [
        for (final tab in tabs)
          NavigationDestination(
            icon: Icon(tab.icon),
            label: tab.label,
          ),
      ],
    );
  }
} 

class _BroadcastTabPage extends StatefulWidget {
  final String? adminUsername;

  const _BroadcastTabPage({
    required this.adminUsername,
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