import 'package:flutter/material.dart';
import '../services/address_autocomplete_service.dart';

class AddressAutocompleteField extends StatefulWidget {
  final String label;
  final String? hint;
  final String? initialValue;
  final ValueChanged<AddressDetails?>? onAddressSelected;
  final ValueChanged<String>? onTextChanged;
  final TextEditingController? controller;
  final bool enabled;
  final String? Function(String?)? validator;

  const AddressAutocompleteField({
    Key? key,
    required this.label,
    this.hint,
    this.initialValue,
    this.onAddressSelected,
    this.onTextChanged,
    this.controller,
    this.enabled = true,
    this.validator,
  }) : super(key: key);

  @override
  State<AddressAutocompleteField> createState() => _AddressAutocompleteFieldState();
}

class _AddressAutocompleteFieldState extends State<AddressAutocompleteField> {
  late TextEditingController _controller;
  List<AddressSuggestion> _suggestions = [];
  bool _isLoading = false;
  bool _showSuggestions = false;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }
    
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _hideSuggestions();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _hideSuggestions();
    super.dispose();
  }

  void _showSuggestionsOverlay() {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width - 32,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 50),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = _suggestions[index];
                  return ListTile(
                    dense: true,
                    title: Text(
                      suggestion.mainText,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: suggestion.secondaryText.isNotEmpty
                        ? Text(
                            suggestion.secondaryText,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          )
                        : null,
                    onTap: () => _selectSuggestion(suggestion),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideSuggestions() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _showSuggestions = false;
    });
  }

  Future<void> _searchAddresses(String query) async {
    if (query.length < 3) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      _hideSuggestions();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final suggestions = await AddressAutocompleteService.getAddressSuggestions(
        input: query,
        countryCode: 'us', // You can make this configurable
      );

      setState(() {
        _suggestions = suggestions;
        _showSuggestions = suggestions.isNotEmpty;
      });

      if (_showSuggestions) {
        _showSuggestionsOverlay();
      } else {
        _hideSuggestions();
      }
    } catch (e) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      _hideSuggestions();
      // You might want to show an error message here
      debugPrint('Address search error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectSuggestion(AddressSuggestion suggestion) async {
    _controller.text = suggestion.description;
    _hideSuggestions();
    
    try {
      final addressDetails = await AddressAutocompleteService.getAddressDetails(
        placeId: suggestion.placeId,
      );
      
      if (addressDetails != null) {
        widget.onAddressSelected?.call(addressDetails);
      }
    } catch (e) {
      debugPrint('Failed to get address details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        controller: _controller,
        focusNode: _focusNode,
        enabled: widget.enabled,
        validator: widget.validator,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          suffixIcon: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : const Icon(Icons.search),
          border: const OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red.shade300),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red.shade500),
          ),
        ),
        onChanged: (value) {
          widget.onTextChanged?.call(value);
          _searchAddresses(value);
        },
        onTap: () {
          if (_suggestions.isNotEmpty) {
            _showSuggestionsOverlay();
          }
        },
      ),
    );
  }
}

class AddressFormField extends StatefulWidget {
  final String label;
  final String? hint;
  final String? initialValue;
  final ValueChanged<AddressDetails?>? onAddressSelected;
  final TextEditingController? controller;
  final bool enabled;
  final String? Function(String?)? validator;

  const AddressFormField({
    Key? key,
    required this.label,
    this.hint,
    this.initialValue,
    this.onAddressSelected,
    this.controller,
    this.enabled = true,
    this.validator,
  }) : super(key: key);

  @override
  State<AddressFormField> createState() => _AddressFormFieldState();
}

class _AddressFormFieldState extends State<AddressFormField> {
  late TextEditingController _controller;
  AddressDetails? _selectedAddress;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onAddressSelected(AddressDetails? address) {
    setState(() {
      _selectedAddress = address;
    });
    widget.onAddressSelected?.call(address);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AddressAutocompleteField(
          label: widget.label,
          hint: widget.hint,
          controller: _controller,
          enabled: widget.enabled,
          validator: widget.validator,
          onAddressSelected: _onAddressSelected,
        ),
        if (_selectedAddress != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Address:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedAddress!.formattedAddress,
                  style: const TextStyle(fontSize: 14),
                ),
                if (_selectedAddress!.latitude != 0 && _selectedAddress!.longitude != 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Coordinates: ${_selectedAddress!.latitude.toStringAsFixed(6)}, ${_selectedAddress!.longitude.toStringAsFixed(6)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}
