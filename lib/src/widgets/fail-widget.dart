import 'package:flutter/material.dart';

class FailWidget extends StatelessWidget {
  final String desc;

  final String title;

  final String button;

  final VoidCallback? onTryAgain;

  const FailWidget({Key? key, this.title = 'Essa não! Algo deu errado', this.desc = 'Um erro ocorreu ao processarmos essa solicitação', this.button = 'Tentar de novo', this.onTryAgain})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [Expanded(child: Text(title)), Expanded(child: Text(desc)), if (onTryAgain != null) TextButton(onPressed: onTryAgain, child: Text(button))],
        ),
      ),
    );
  }
}
