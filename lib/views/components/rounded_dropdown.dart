import 'package:flutter/material.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/views/components/text_field_container.dart';

class RoundedDropDown extends StatelessWidget {
  final String title;
  final String hintText;
  final IconData icon;
  final ValueChanged onChanged;
  final FormFieldValidator validator;
  final List<DropdownMenuItem<Object>> items;
  final dynamic value;
  final bool isExpanded;

  const RoundedDropDown({
    Key? key,
    required this.hintText,
    required this.icon,
    required this.onChanged,
    required this.validator,
    required this.items,
    required this.value,
    required this.isExpanded,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  title + ":",
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              )
            : const SizedBox.shrink(),
        TextFieldContainer(
          child: DropdownButtonFormField(
            autofocus: false,
            validator: validator,
            onChanged: onChanged,
            iconEnabledColor: Colors.black45,
            dropdownColor: kPrimaryLightColor,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: Colors.black45),
              icon: Icon(
                icon,
                color: kPrimaryColor,
              ),
              border: InputBorder.none,
            ),
            items: items,
            value: value,
            isExpanded: isExpanded,
          ),
        ),
      ],
    );
  }
}
