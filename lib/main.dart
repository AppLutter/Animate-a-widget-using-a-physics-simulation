import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

void main() {
  runApp(const MaterialApp(home: PhysicsCardDragDemo()));
}

class PhysicsCardDragDemo extends StatelessWidget {
  const PhysicsCardDragDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const DraggableCard(
        child: FlutterLogo(
          size: 128,
        ),
      ),
    );
  }
}

class DraggableCard extends StatefulWidget {
  const DraggableCard({required this.child, super.key});

  final Widget child;

  @override
  State<DraggableCard> createState() => _DraggableCardState();
}

class _DraggableCardState extends State<DraggableCard> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Alignment> animation;
  Alignment dragAlignment = Alignment.center;

  void runAnimation(Offset pixelsPerSecond, Size size) {
    /// 시작 후 항상 중앙으로 돌아오게끔 설계
    animation = controller.drive(
      AlignmentTween(
        begin: dragAlignment,
        end: Alignment.center,
      ),
    );

    final unitsPerSecondsX = pixelsPerSecond.dx / (size.width);
    final unitsPerSecondsY = pixelsPerSecond.dy / (size.height);
    final unitsPerSeconds = Offset(unitsPerSecondsX, unitsPerSecondsY);
    final unitVelocity = unitsPerSeconds.distance;

    const spring = SpringDescription(
      /// 질량
      /// 커질수록 돌아오는 속도 빨라짐(반동이 세짐)
      /// 커질수록 이동 느려짐, 작을 수록 이동 빠름
      mass: 30,

      /// 강성
      /// 커질수록 돌아오면 띠용하고 흔들림
      stiffness: 1,

      /// 감쇠
      /// 커질수록 돌아갈 때 일정량만 튕기고
      /// 나머지 부분 천천히 돌아감
      damping: 100,
    );

    final simulation = SpringSimulation(spring, 0, 1, unitVelocity);

    controller.animateWith(simulation);
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    controller.addListener(() {
      setState(() {
        dragAlignment = animation.value;
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onPanDown: (details) {
        /// onPanEnd이 발동해서 다시 돌아갈 때
        /// 위젯을 다시 잡고 싶으면 현재 진행중인 애니메이션 멈추어야 함.. 그 목적
        controller.stop();
      },
      onPanUpdate: (details) {
        setState(
          () {
            /// 값을 더해줘야 움직임 !!!! = 아님 += !!
            dragAlignment += Alignment(
              details.delta.dx / (size.width / 2),
              details.delta.dy / (size.height / 2),
            );
          },
        );
      },
      onPanEnd: (details) {
        /// 터치가 끝나면 다시 중앙으로 오게끔 함
        runAnimation(details.velocity.pixelsPerSecond, size);
      },
      child: Align(
        alignment: dragAlignment,
        child: Card(
          child: widget.child,
        ),
      ),
    );
  }
}
