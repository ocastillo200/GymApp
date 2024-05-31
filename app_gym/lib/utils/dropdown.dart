import 'package:flutter/material.dart';

class DropdownSearch extends StatefulWidget {
  final List<String> items;
  final int maxSuggestions;

  DropdownSearch({
    required this.items,
    required this.maxSuggestions,
  });

  @override
  _DropdownSearchState createState() => _DropdownSearchState();
}

class _DropdownSearchState extends State<DropdownSearch> {
  String _selectedItem = '';
  List<String> _filteredItems = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items.take(widget.maxSuggestions).toList();
    _searchController.addListener(_filterItems);
  }

  void _filterItems() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = widget.items
          .where((item) => item.toLowerCase().contains(query))
          .take(widget.maxSuggestions)
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterItems);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: 'Search',
            suffixIcon: Icon(Icons.search),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredItems.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_filteredItems[index]),
                onTap: () {
                  setState(() {
                    _selectedItem = _filteredItems[index];
                  });
                },
              );
            },
          ),
        ),
        SizedBox(height: 20),
        Text(
          'Selected Item: $_selectedItem',
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
