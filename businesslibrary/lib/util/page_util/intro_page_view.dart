import 'package:businesslibrary/util/page_util/data.dart';
import 'package:businesslibrary/util/page_util/intro_page_item.dart';
import 'package:businesslibrary/util/page_util/page_transformer.dart';
import 'package:flutter/material.dart';

class IntroPageView extends StatelessWidget {
  final List<IntroItem> items;

  IntroPageView(this.items);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BFN Onboarding'),
      ),
      backgroundColor: Colors.brown.shade100,
      body: Center(
        child: SizedBox.fromSize(
          size: const Size.fromHeight(double.infinity),
          child: PageTransformer(
            pageViewBuilder: (context, visibilityResolver) {
              return PageView.builder(
                controller: PageController(viewportFraction: 0.90), pageSnapping: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final pageVisibility =
                      visibilityResolver.resolvePageVisibility(index);

                  return IntroPageItem(
                    item: item,
                    pageVisibility: pageVisibility,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
