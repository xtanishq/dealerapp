import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/notification/notification_bloc.dart';
import '../blocs/notification/notification_event.dart';
import '../blocs/notification/notification_state.dart';
import '../blocs/theme/theme_cubit.dart';
import 'login_screen.dart';

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {

  final ScrollController _scrollController = ScrollController();
  
  String? _selectedType;
  String? _selectedCategory;
  String? _selectedLanguage;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationBloc>().add(LoadNotificationsEvent());
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Check if user has scrolled to 90% of the list
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      final state = context.read<NotificationBloc>().state;

      if (state is NotificationLoaded && state.hasMore) {
        context.read<NotificationBloc>().add(LoadMoreNotificationsEvent());
      }
    }
  }

  void _applyFilters() {
    context.read<NotificationBloc>().add(
          LoadNotificationsEvent(
            type: _selectedType,
            category: _selectedCategory,
            language: _selectedLanguage,
          ),
        );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filters'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Type filter dropdown
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Type'),
                items: const [
                  DropdownMenuItem(value: null, child: Text('All')),
                  DropdownMenuItem(value: 'waitage', child: Text('Waitage')),
                  DropdownMenuItem(value: 'local', child: Text('Local')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: const [
                  DropdownMenuItem(value: null, child: Text('All')),
                  DropdownMenuItem(value: 'tractor', child: Text('Tractor')),
                  DropdownMenuItem(value: 'vehicle', child: Text('Vehicle')),
                  DropdownMenuItem(value: 'harvester', child: Text('Harvester')),
                  DropdownMenuItem(value: 'implements', child: Text('Implements')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Language filter dropdown
              DropdownButtonFormField<String>(
                value: _selectedLanguage,
                decoration: const InputDecoration(labelText: 'Language'),
                items: const [
                  DropdownMenuItem(value: null, child: Text('All')),
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'hi', child: Text('Hindi')),
                  DropdownMenuItem(value: 'bn', child: Text('Bengali')),
                  DropdownMenuItem(value: 'mr', child: Text('Marathi')),
                  DropdownMenuItem(value: 'ml', child: Text('Malayalam')),
                  DropdownMenuItem(value: 'or', child: Text('Oriya')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value;
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _applyFilters();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _logout() {

    context.read<AuthBloc>().add(LogoutEvent());
    
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        actions: [

          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              final isDark = themeMode == ThemeMode.dark || 
                             (themeMode == ThemeMode.system && 
                              MediaQuery.of(context).platformBrightness == Brightness.dark);
              
              return IconButton(
                icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                onPressed: () {
                  // Toggle theme
                  context.read<ThemeCubit>().toggleTheme();
                },
                tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
              );
            },
          ),
          
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter notifications',
          ),

          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: BlocConsumer<NotificationBloc, NotificationState>(
        listener: (context, state) {
          // Handle errors
          if (state is NotificationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          // Handle unauthorized state (401 error)
          if (state is NotificationUnauthorized) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Session expired. Please login again.')),
              );
              _logout();
            });
            return const Center(
              child: Text('Session expired'),
            );
          }

          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationLoaded || state is NotificationLoadingMore) {
            final notifications = state is NotificationLoaded
                ? state.notifications
                : (state as NotificationLoadingMore).notifications;

            if (notifications.isEmpty) {
              return const Center(
                child: Text('No notifications found'),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<NotificationBloc>().add(RefreshNotificationsEvent());
                
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: ListView.builder(
                controller: _scrollController,
                itemCount: notifications.length + 1,
                itemBuilder: (context, index) {

                  if (index == notifications.length) {

                    if (state is NotificationLoadingMore) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (state is NotificationLoaded && !state.hasMore) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: Text('No more notifications')),
                      );
                    }
                    return const SizedBox.shrink();
                  }

                  final notification = notifications[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      leading: notification.image != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                notification.image!,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return CircleAvatar(
                                    child: Text('${index + 1}'),
                                  );
                                },
                              ),
                            )
                          : CircleAvatar(
                              child: Text('${index + 1}'),
                            ),
                      
                      title: Text(
                        notification.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (notification.description != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(notification.description!),
                            ),
                          
                          if (notification.location != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      notification.location!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Wrap(
                              spacing: 8,
                              children: [
                                if (notification.category != null)
                                  Chip(
                                    label: Text(notification.category!),
                                    labelStyle: const TextStyle(fontSize: 12),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                if (notification.type != null)
                                  Chip(
                                    label: Text(notification.type!),
                                    labelStyle: const TextStyle(fontSize: 12),
                                    visualDensity: VisualDensity.compact,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
            );
          }

          return const Center(child: Text('Something went wrong'));
        },
      ),
    );
  }
}
