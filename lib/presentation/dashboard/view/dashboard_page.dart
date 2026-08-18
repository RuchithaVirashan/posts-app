import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/post.dart';
import '../../../domain/entities/user.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../bloc/posts_bloc.dart';
import '../bloc/posts_event.dart';
import '../bloc/posts_state.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/featured_post_card.dart';
import '../widgets/post_card.dart';
import '../widgets/search_field.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, this.onProfileTap});

  final VoidCallback? onProfileTap;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final nearBottom =
        _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200;
    if (nearBottom) {
      context.read<PostsBloc>().add(const PostsNextPageRequested());
    }
  }

  Future<void> _onRefresh() {
    final bloc = context.read<PostsBloc>();
    bloc.add(const PostsRefreshRequested());
    return bloc.stream.firstWhere(
      (state) => state.status != PostsStatus.loading,
    );
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning!';
    if (hour < 17) return 'Good Afternoon!';
    return 'Good Evening!';
  }

  List<Post> _featuredPosts(List<Post> posts) {
    final sorted = [...posts]..sort((a, b) => b.likes.compareTo(a.likes));
    return sorted.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: BlocListener<PostsBloc, PostsState>(
        listenWhen: (previous, current) =>
            current.failure != null &&
            current.status == PostsStatus.success &&
            current.posts.isNotEmpty,
        listener: (context, state) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                backgroundColor: AppColors.critical,
                content: Text(state.failure!.message),
              ),
            );
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_greeting, style: AppTextStyles.headline),
                      _ProfileAvatar(onTap: widget.onProfileTap),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SearchField(
                    controller: _searchController,
                    onChanged: (value) => context.read<PostsBloc>().add(
                      PostsSearchChanged(value),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<PostsBloc, PostsState>(
                builder: (context, state) {
                  switch (state.status) {
                    case PostsStatus.initial:
                    case PostsStatus.loading:
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    case PostsStatus.failure:
                      return ErrorState(
                        message: state.failure?.message ??
                            'Something went wrong.',
                        onRetry: () => context.read<PostsBloc>().add(
                          const PostsRefreshRequested(),
                        ),
                      );
                    case PostsStatus.empty:
                      return RefreshIndicator(
                        onRefresh: _onRefresh,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 80),
                            EmptyState(message: 'No posts found.'),
                          ],
                        ),
                      );
                    case PostsStatus.success:
                    case PostsStatus.loadingMore:
                      final featured = _featuredPosts(state.posts);
                      final isLoadingMore =
                          state.status == PostsStatus.loadingMore;
                      return RefreshIndicator(
                        onRefresh: _onRefresh,
                        child: ListView.builder(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 20),
                          itemCount:
                              1 + state.posts.length + (isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                children: [
                                  if (featured.isNotEmpty) ...[
                                    const _SectionHeader(
                                      title: 'Featured Posts',
                                    ),
                                    SizedBox(
                                      height: 210,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                        ),
                                        itemCount: featured.length,
                                        separatorBuilder: (_, _) =>
                                            const SizedBox(width: 12),
                                        itemBuilder: (context, i) =>
                                            FeaturedPostCard(
                                              post: featured[i],
                                            ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                  const _SectionHeader(title: 'Recent Posts'),
                                ],
                              );
                            }
                            final postIndex = index - 1;
                            if (postIndex >= state.posts.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                0,
                                20,
                                12,
                              ),
                              child: PostCard(post: state.posts[postIndex]),
                            );
                          },
                        ),
                      );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.title),
          Text('View All', style: AppTextStyles.link),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        backgroundColor: AppColors.primary,
        radius: 20,
        child: Text(
          _initials(user),
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _initials(User? user) {
    if (user == null) return '?';
    final first = user.firstName?.isNotEmpty == true
        ? user.firstName![0]
        : user.username[0];
    final last = user.lastName?.isNotEmpty == true ? user.lastName![0] : '';
    return '$first$last'.toUpperCase();
  }
}
