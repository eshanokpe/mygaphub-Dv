import 'package:GapHub/screens/portfolio/assetclasses.dart';
import 'package:GapHub/utils/connectTo.dart';
import 'package:GapHub/widgets/avatarImage.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PortfolioHeader extends StatelessWidget implements PreferredSizeWidget {
  const PortfolioHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return AppBar(
      backgroundColor: Colors.white,
      title: const Text('', style: TextStyle(fontWeight: FontWeight.bold)),
      centerTitle: true,
      automaticallyImplyLeading: false,
      elevation: 0,
      leading: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * .03),
        child: Image.asset('assets/logo.png'),
      ),
      actions: [
        IconButton(
          onPressed: () {
            getAssetClasses(context, () async {
              context.read<Providers>().addAssetAcquisition(
                context.read<Providers>().httpData,
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AssetClasses(const ["existing"]),
                ),
              );
            });
          },
          icon: const Icon(Icons.add, size: 25, color: Colors.black),
        ),
        const AvatarImage(),
      ],
    );
  }

  getAssetClasses(context, Function doing) {
    connectTo(context, "get", "/app/portfolio/information", {}, shoot: doing);
  }
}
