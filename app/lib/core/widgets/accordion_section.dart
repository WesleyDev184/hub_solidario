import 'package:app/core/theme/custom_colors.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// AccordionSection: Um componente de acordeon reutilizável para seções expansíveis.
class AccordionSection extends StatefulWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final bool collapsible;
  final bool initiallyExpanded;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? titleColor;
  final Color? borderColor;
  final Color? shadowColor;
  final Color? headerGradientStart;
  final Color? headerGradientEnd;
  final double? marginVertical;
  final double? borderRadius;

  const AccordionSection({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    this.collapsible = true,
    this.initiallyExpanded = true,
    this.backgroundColor = const Color(
      0x00000000,
    ), // Transparent, will use CustomColors.primary.withOpacity(0.015)
    this.iconColor,
    this.titleColor,
    this.borderColor,
    this.shadowColor,
    this.headerGradientStart,
    this.headerGradientEnd,
    this.marginVertical,
    this.borderRadius,
  });

  @override
  State<AccordionSection> createState() => _AccordionSectionState();
}

class _AccordionSectionState extends State<AccordionSection> {
  late bool expanded;

  @override
  void initState() {
    super.initState();
    expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: widget.marginVertical ?? 12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color:
            widget.backgroundColor ?? CustomColors.primary.withOpacity(0.015),
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 18),
        border: Border.all(
          color: widget.borderColor ?? CustomColors.primary.withOpacity(0.06),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.shadowColor ?? CustomColors.primary.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: widget.collapsible
                ? () {
                    setState(() {
                      expanded = !expanded;
                    });
                  }
                : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.headerGradientStart ??
                        CustomColors.primary.withOpacity(0.05),
                    widget.headerGradientEnd ??
                        CustomColors.primary.withOpacity(0.01),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: CustomColors.primary.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      widget.icon,
                      color:
                          widget.iconColor ??
                          CustomColors.primary.withOpacity(0.7),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color:
                            widget.titleColor ??
                            CustomColors.primary.withOpacity(0.7),
                      ),
                    ),
                  ),
                  if (widget.collapsible)
                    Icon(
                      expanded
                          ? LucideIcons.chevronUp
                          : LucideIcons.chevronDown,
                      color:
                          widget.iconColor ??
                          CustomColors.primary.withOpacity(0.7),
                      size: 20,
                    ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(children: widget.children),
            ),
            crossFadeState: expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
            firstCurve: Curves.easeInOut,
            secondCurve: Curves.easeInOut,
          ),
        ],
      ),
    );
  }
}
