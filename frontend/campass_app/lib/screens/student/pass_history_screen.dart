// lib/screens/student/pass_history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../widgets/gradient_background.dart';
import '../../providers/pass_provider.dart';
import '../../models/pass_model.dart';
import '../../utils/error_handler.dart';
import '../../utils/cache_manager.dart';
import '../../widgets/loading_widget.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';

class PassHistoryScreen extends StatefulWidget {
  final String userId;
  final String token;

  const PassHistoryScreen({
    super.key,
    required this.userId,
    required this.token,
  });

  @override
  State<PassHistoryScreen> createState() => _PassHistoryScreenState();
}

class _PassHistoryScreenState extends State<PassHistoryScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _loadPasses();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadPasses() async {
    try {
      final passProvider = Provider.of<PassProvider>(context, listen: false);
      await passProvider.loadPasses(widget.userId, widget.token);

      // Cache the passes for offline
      final passes = passProvider.passes;
      await CacheManager.cachePasses(
        passes.map((pass) => pass.toJson()).toList(),
      );
    } catch (e) {
      // Try to load from cache
      try {
        final cachedPasses = await CacheManager.getCachedPasses();
        if (cachedPasses.isNotEmpty && mounted) {
          final passProvider = Provider.of<PassProvider>(context, listen: false);
          passProvider.setPasses(
            cachedPasses.map((json) => PassModel.fromJson(json)).toList(),
          );
          ErrorHandler.showErrorSnackBar(
            context,
            'Loaded cached data. Please check connection.',
          );
        } else {
          ErrorHandler.showErrorSnackBar(
            context,
            ErrorHandler.getErrorMessage(e),
          );
        }
      } catch (cacheError) {
        ErrorHandler.showErrorSnackBar(
          context,
          ErrorHandler.getErrorMessage(e),
        );
      }
    }
  }

  Future<void> _refreshPasses() async {
    await _loadPasses();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'expired':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Icons.check_circle;
      case 'expired':
        return Icons.cancel;
      case 'pending':
        return Icons.hourglass_empty;
      case 'approved':
        return Icons.thumb_up;
      case 'rejected':
        return Icons.thumb_down;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Pass History', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GradientBackground(
        child: Consumer<PassProvider>(
          builder: (context, passProvider, child) {
            if (passProvider.isLoading) {
              return const LoadingWidget(message: 'Loading passes...');
            }

            if (passProvider.passes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      size: 80,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No passes found',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshPasses,
                      child: const Text('Refresh'),
                    ),
                  ],
                ),
              );
            }

            return FadeTransition(
              opacity: _fadeAnimation,
              child: RefreshIndicator(
                onRefresh: _refreshPasses,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 100, 16, 16), // Added top padding for AppBar
                  itemCount: passProvider.passes.length,
                  itemBuilder: (context, index) {
                    final pass = passProvider.passes[index];
                    return _buildPassCard(pass, index);
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPassCard(PassModel pass, int index) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final delay = index * 0.1;
        final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(delay, 1.0, curve: Curves.elasticOut),
          ),
        );

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(animation),
            child: PassHistoryCard(pass: pass),
          ),
        );
      },
    );
  }
}

class PassHistoryCard extends StatefulWidget {
  final PassModel pass;

  const PassHistoryCard({super.key, required this.pass});

  @override
  State<PassHistoryCard> createState() => _PassHistoryCardState();
}

class _PassHistoryCardState extends State<PassHistoryCard> {
  bool _isExpanded = false;

  void _toggleExpand() {
    setState(() => _isExpanded = !_isExpanded);
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy • hh:mm a').format(date.toLocal());
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active': return Colors.green;
      case 'expired': return Colors.red;
      case 'pending': return Colors.orange;
      case 'approved': return Colors.blue;
      case 'rejected': return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'active': return Icons.check_circle;
      case 'expired': return Icons.cancel;
      case 'pending': return Icons.hourglass_empty;
      case 'approved': return Icons.thumb_up;
      case 'rejected': return Icons.thumb_down;
      default: return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Always Visible)
                InkWell(
                  onTap: _toggleExpand,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left: Purpose & ID
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.pass.purpose ?? 'Genral Outing',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Pass #${widget.pass.id.substring(0, 8).toUpperCase()}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 12,
                                  fontFamily: 'Courier',
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Right: Status & Arrow
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(widget.pass.status).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getStatusColor(widget.pass.status),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _getStatusIcon(widget.pass.status),
                                    color: _getStatusColor(widget.pass.status),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.pass.status.toUpperCase(),
                                    style: TextStyle(
                                      color: _getStatusColor(widget.pass.status),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Expanded Details
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(color: Colors.white24),
                        const SizedBox(height: 8),
                        _buildDetailRow(Icons.calendar_today, 'Valid From', _formatDate(widget.pass.validFrom)),
                        const SizedBox(height: 8),
                        _buildDetailRow(Icons.event_available, 'Valid To', _formatDate(widget.pass.validTo)),
                        const SizedBox(height: 8),
                        _buildDetailRow(Icons.category, 'Type', widget.pass.type),
                        
                        // QR Code Section
                        const SizedBox(height: 20),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: QrImageView(
                              data: widget.pass.id,
                              version: QrVersions.auto,
                              size: 140.0,
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white.withOpacity(0.7)),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
