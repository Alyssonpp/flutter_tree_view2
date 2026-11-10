import 'package:flutter_fancy_tree_view2/flutter_fancy_tree_view2.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  for (final animated in [false, true]) {
    for (final brightness in Brightness.values) {
      testWidgets('Material tree expands: animated=$animated, $brightness', (
        tester,
      ) async {
        const root = _Node('Root', [_Node('Child')]);
        final controller = TreeController<_Node>(
          roots: const [root],
          childrenProvider: (node) => node.children,
        );
        addTearDown(controller.dispose);

        Widget nodeBuilder(BuildContext context, TreeEntry<_Node> entry) {
          return TreeIndentation(
            entry: entry,
            child: Row(
              children: [
                FolderButton(
                  key: ValueKey(entry.node.title),
                  isOpen: entry.hasChildren ? entry.isExpanded : null,
                  style: IconButton.styleFrom(foregroundColor: Colors.teal),
                  onPressed: entry.hasChildren
                      ? () => controller.toggleExpansion(entry.node)
                      : null,
                ),
                Text(entry.node.title),
              ],
            ),
          );
        }

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.teal,
                brightness: brightness,
              ),
            ),
            home: Scaffold(
              body: animated
                  ? AnimatedTreeView<_Node>(
                      treeController: controller,
                      nodeBuilder: nodeBuilder,
                    )
                  : TreeView<_Node>(
                      treeController: controller,
                      nodeBuilder: nodeBuilder,
                    ),
            ),
          ),
        );

        expect(find.text('Root'), findsOneWidget);
        expect(find.text('Child'), findsNothing);
        expect(find.byIcon(Icons.folder), findsOneWidget);

        await tester.tap(find.byKey(const ValueKey('Root')));
        await tester.pumpAndSettle();

        expect(find.text('Child'), findsOneWidget);
        expect(find.byIcon(Icons.folder_open), findsOneWidget);
        expect(find.byIcon(Icons.article), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.tap(find.byKey(const ValueKey('Root')));
        await tester.pumpAndSettle();

        expect(find.text('Child'), findsNothing);
        expect(find.byIcon(Icons.folder), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }
}

class _Node {
  const _Node(this.title, [this.children = const []]);

  final String title;
  final List<_Node> children;
}
