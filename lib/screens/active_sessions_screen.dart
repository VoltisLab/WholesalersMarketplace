import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../services/graphql_service.dart';
import '../services/token_service.dart';
import '../services/error_service.dart';

class ActiveSessionsScreen extends StatefulWidget {
  const ActiveSessionsScreen({super.key});

  @override
  State<ActiveSessionsScreen> createState() => _ActiveSessionsScreenState();
}

class _ActiveSessionsScreenState extends State<ActiveSessionsScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _sessions = [];
  String? _currentSessionId;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Please log in to view sessions');
      }

      final result = await AuthService.getActiveSessions(token: token);
      
      setState(() {
        _sessions = List<Map<String, dynamic>>.from(result['sessions'] ?? []);
        _currentSessionId = result['currentSessionId'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading sessions: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _terminateSession(String sessionId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Please log in to terminate sessions');
      }

      await AuthService.terminateSession(token: token, sessionId: sessionId);
      
      // Reload sessions after termination
      await _loadSessions();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Session terminated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error terminating session: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _terminateAllOtherSessions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Please log in to terminate sessions');
      }

      await AuthService.terminateAllOtherSessions(token: token);
      
      // Reload sessions after termination
      await _loadSessions();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('All other sessions terminated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error terminating sessions: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Sessions'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          if (_sessions.length > 1)
            TextButton(
              onPressed: _terminateAllOtherSessions,
              child: const Text(
                'End All Others',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadSessions,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    if (_sessions.isEmpty)
                      _buildEmptyState()
                    else
                      _buildSessionsList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Manage Your Sessions',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'View and manage all devices where you\'re currently logged in. You can terminate any session to sign out from that device.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 60),
          Icon(
            Icons.devices_other,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No Active Sessions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You don\'t have any active sessions at the moment.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsList() {
    return Column(
      children: _sessions.map((session) => _buildSessionCard(session)).toList(),
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> session) {
    final isCurrentSession = session['id'] == _currentSessionId;
    final deviceName = session['deviceName'] ?? 'Unknown Device';
    final deviceType = session['deviceType'] ?? 'Unknown';
    final location = session['location'] ?? 'Unknown Location';
    final lastActive = session['lastActive'] ?? '';
    final ipAddress = session['ipAddress'] ?? 'Unknown IP';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getDeviceIcon(deviceType),
                  size: 24,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            deviceName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (isCurrentSession) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.success,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Current',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$deviceType • $location',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isCurrentSession)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'terminate') {
                        _showTerminateConfirmation(session);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'terminate',
                        child: Row(
                          children: [
                            Icon(Icons.logout, color: AppColors.error),
                            SizedBox(width: 8),
                            Text('Terminate Session'),
                          ],
                        ),
                      ),
                    ],
                    child: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Last active: $lastActive',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'IP: $ipAddress',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getDeviceIcon(String deviceType) {
    switch (deviceType.toLowerCase()) {
      case 'mobile':
      case 'iphone':
      case 'android':
        return Icons.phone_android;
      case 'tablet':
      case 'ipad':
        return Icons.tablet;
      case 'desktop':
      case 'windows':
      case 'mac':
      case 'linux':
        return Icons.desktop_windows;
      case 'web':
        return Icons.web;
      default:
        return Icons.devices_other;
    }
  }

  void _showTerminateConfirmation(Map<String, dynamic> session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terminate Session'),
        content: Text(
          'Are you sure you want to terminate the session for "${session['deviceName'] ?? 'Unknown Device'}"? This will sign out the device immediately.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _terminateSession(session['id']);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Terminate'),
          ),
        ],
      ),
    );
  }
}
