import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../models/view_state.dart';
import '../repositories/meal_repository.dart';
import 'meal_detail_screen.dart';
import '../widgets/meal_card.dart';

class MealListScreen extends StatefulWidget {
  const MealListScreen({super.key});

  @override
  State<MealListScreen> createState() => _MealListScreenState();
}

class _MealListScreenState extends State<MealListScreen> {
  final MealRepository _repository = MealRepository();
  final ScrollController _scrollController = ScrollController();

  static const int _pageSize = 6;

  List<Meal> _allMeals = [];
  List<Meal> _displayedMeals = [];

  ViewStatus _status = ViewStatus.loading;
  String _errorMessage = '';

  int _currentPage = 0;
  bool _isLoadingMore = false;
  @override
  void initState() {
    super.initState();
    _loadMeals();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll >= maxScroll - 200) {
      _loadNextPage();
    }
  }

  Future<void> _loadMeals() async {
    setState(() {
      _status = ViewStatus.loading;
    });

    try {
      final meals = await _repository.getMeals();

      setState(() {
        _allMeals = meals;
        _currentPage = 0;
        _displayedMeals = _allMeals.take(_pageSize).toList();
        _currentPage = 1;
        _status = _allMeals.isEmpty ? ViewStatus.empty : ViewStatus.success;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _status = ViewStatus.error;
      });
    }
  }

  void _loadNextPage() {
    if (_isLoadingMore) return;
    if (_displayedMeals.length >= _allMeals.length) return;

    setState(() {
      _isLoadingMore = true;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      final nextItems = _allMeals
          .skip(_currentPage * _pageSize)
          .take(_pageSize);

      setState(() {
        _displayedMeals.addAll(nextItems);
        _currentPage++;
        _isLoadingMore = false;
      });
    });
  }

  Future<void> _onRefresh() async {
    await _loadMeals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yeməklər')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_status) {
      case ViewStatus.loading:
        return const Center(child: CircularProgressIndicator());

      case ViewStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Text(_errorMessage, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadMeals,
                  child: const Text('Yenidən cəhd et'),
                ),
              ],
            ),
          ),
        );

      case ViewStatus.empty:
        return const Center(child: Text('Heç bir yemək tapılmadı.'));

      case ViewStatus.success:
        return RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView.builder(
            controller: _scrollController,
            itemCount: _displayedMeals.length + (_isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= _displayedMeals.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final meal = _displayedMeals[index];
              return MealCard(
                meal: meal,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MealDetailScreen(mealId: meal.id),
                    ),
                  );
                },
              );
            },
          ),
        );
    }
  }
}
