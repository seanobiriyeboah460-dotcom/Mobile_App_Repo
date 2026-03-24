import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/quote_viewmodel.dart';
import 'event_list_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final quoteVm = Provider.of<QuoteViewModel>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Campus Connect')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Quote of the day',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 8),
                    if (quoteVm.isLoading)
                      CircularProgressIndicator()
                    else if (quoteVm.errorMessage != null)
                      Text('Failed to load quote')
                    else
                      Text(
                        '"${quoteVm.currentQuote?.text}" - ${quoteVm.currentQuote?.author}',
                      ),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => quoteVm.loadRandomQuote(),
                      child: Text('New Quote'),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EventListScreen()),
              ),
              child: Text('View Events'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfileScreen()),
              ),
              child: Text('My Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
