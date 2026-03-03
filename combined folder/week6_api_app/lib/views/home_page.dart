import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/article_viewmodel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ArticleViewModel>(context);

    return DefaultTabController(
      length: 3,
      initialIndex: viewModel.selectedCategory.index,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('API Consumer App'),
          bottom: TabBar(
            onTap: (index) {
              final category = Category.values[index];
              viewModel.setCategory(category);
            },
            tabs: const [
              Tab(text: 'News'),
              Tab(text: 'Weather'),
              Tab(text: 'Crypto'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => viewModel.refresh(),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildNews(context, viewModel),
            _buildWeather(context, viewModel),
            _buildCrypto(context, viewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildNews(BuildContext context, ArticleViewModel viewModel) {
    if (viewModel.isLoading && viewModel.articles.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null) {
      return _buildError(
        context,
        viewModel.errorMessage!,
        onRetry: viewModel.loadData,
      );
    }

    if (viewModel.articles.isEmpty) {
      return const Center(child: Text('No articles available'));
    }

    return RefreshIndicator(
      onRefresh: viewModel.refresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: viewModel.articles.length,
        itemBuilder: (context, index) {
          final article = viewModel.articles[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (article.imageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        article.imageUrl!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: Colors.amber[300],
                            child: const Center(
                              child: Text('Image not available'),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        article.source,
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _formatDate(article.publishedAt),
                        style: TextStyle(
                          color: const Color.fromARGB(255, 70, 66, 66),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeather(BuildContext context, ArticleViewModel viewModel) {
    if (viewModel.isLoading && viewModel.weather == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null) {
      return _buildError(
        context,
        viewModel.errorMessage!,
        onRetry: viewModel.loadData,
      );
    }

    if (viewModel.weather == null) {
      return const Center(child: Text('No weather data'));
    }

    final w = viewModel.weather!;
    // background from bundled asset
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('lib/download.jpeg', fit: BoxFit.cover),
        Container(color: Colors.black.withOpacity(0.3)),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  w.city,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${w.temperatureCelsius.toStringAsFixed(1)} °C',
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  w.description,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCrypto(BuildContext context, ArticleViewModel viewModel) {
    if (viewModel.isLoading && viewModel.cryptoPrice == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null) {
      return _buildError(
        context,
        viewModel.errorMessage!,
        onRetry: viewModel.loadData,
      );
    }

    if (viewModel.cryptoPrice == null ||
        viewModel.cryptoPrice!.prices.isEmpty) {
      return const Center(child: Text('No crypto data'));
    }

    final prices = viewModel.cryptoPrice!.prices;
    return RefreshIndicator(
      onRefresh: viewModel.refresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: prices.entries.map((e) {
          return ListTile(
            title: Text(e.key),
            trailing: Text('\$${e.value.toStringAsFixed(2)}'),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildError(
    BuildContext context,
    String message, {
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error loading data',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(message),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Try Again')),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return '';
    }
  }
}
