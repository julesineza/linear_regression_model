import 'package:flutter/material.dart';

class HybridDropdownField extends StatelessWidget {
  final TextEditingController controller;
  final List<String> options;
  final String label;
  final String hint;
  final IconData icon;

  const HybridDropdownField({
    Key? key,
    required this.controller,
    required this.options,
    required this.label,
    required this.hint,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return RawAutocomplete<String>(
            textEditingController: controller,
            focusNode: FocusNode(),
            optionsBuilder: (TextEditingValue textEditingValue) {
              final query = textEditingValue.text.trim().toLowerCase();
              if (query.isEmpty) {
                return options;
              }
              return options.where(
                (option) => option.toLowerCase().contains(query),
              );
            },
            fieldViewBuilder: (
              BuildContext context,
              TextEditingController fieldController,
              FocusNode focusNode,
              VoidCallback onFieldSubmitted,
            ) {
              return TextField(
                controller: fieldController,
                focusNode: focusNode,
                decoration: InputDecoration(
                  labelText: label,
                  hintText: hint,
                  prefixIcon: Icon(icon),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (fieldController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          tooltip: 'Clear',
                          onPressed: () {
                            fieldController.clear();
                            focusNode.requestFocus();
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.arrow_drop_down),
                        tooltip: 'Show options',
                        onPressed: () {
                          if (focusNode.hasFocus) {
                            focusNode.unfocus();
                          } else {
                            focusNode.requestFocus();
                          }
                        },
                      ),
                    ],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            optionsViewBuilder: (
              BuildContext context,
              AutocompleteOnSelected<String> onSelected,
              Iterable<String> filteredOptions,
            ) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4.0,
                  borderRadius: BorderRadius.circular(10),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: 220,
                      maxWidth: constraints.maxWidth,
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: filteredOptions.length,
                      itemBuilder: (BuildContext context, int index) {
                        final String option = filteredOptions.elementAt(index);
                        return ListTile(
                          dense: true,
                          title: Text(option),
                          onTap: () => onSelected(option),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}