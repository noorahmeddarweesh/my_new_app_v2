import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final Function(String) onSubmitted;
  final bool showSuggestions;
  final List suggestionResults;
  final Function(dynamic) onSuggestionTap;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.showSuggestions,
    required this.suggestionResults,
    required this.onSuggestionTap,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.grey),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  textInputAction: TextInputAction.search,
                  onSubmitted: widget.onSubmitted,
                  onChanged: widget.onChanged,
                  decoration: const InputDecoration(
                    hintText: "Search...",
                    border: InputBorder.none,
                  ),
                ),
              ),
              const Icon(Icons.tune, color: Colors.grey),
            ],
          ),
        ),
        if (widget.showSuggestions)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: widget.suggestionResults.map((item) {
                return ListTile(
                  leading: Image.network(
                    item['thumbnail'],
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                  ),
                  title: Text(item['title'] ?? ""),
                  subtitle: Text("\$${item['price'] ?? ''}"),
                  onTap: () => widget.onSuggestionTap(item),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}