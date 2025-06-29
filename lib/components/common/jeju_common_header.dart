import 'package:flutter/material.dart';

class JejuCommonHeader extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final List<Widget>? actions;
  final double expandedHeight;

  const JejuCommonHeader({
    Key? key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.actions,
    this.expandedHeight = 80,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      expandedHeight: expandedHeight,
      floating: true,
      snap: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF00A3A3).withOpacity(0.1),
                Color(0xFF00D4AA).withOpacity(0.05),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Text('$emoji ', style: TextStyle(fontSize: 18)),
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF00A3A3),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (actions != null) ...actions!,
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}