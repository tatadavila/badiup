import 'dart:collection';

import 'package:badiup/colors.dart';
import 'package:badiup/constants.dart' as constants;
import 'package:badiup/models/product_model.dart';
import 'package:badiup/models/user_model.dart';
import 'package:badiup/screens/admin_new_product_page.dart';
import 'package:badiup/screens/admin_product_detail_page.dart';
import 'package:badiup/screens/customer_product_detail_page.dart';
import 'package:badiup/sign_in.dart';
import 'package:badiup/test_keys.dart';
import 'package:badiup/utilities.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:transparent_image/transparent_image.dart';

class ProductListing extends StatefulWidget {
  @override
  _ProductListingState createState() => _ProductListingState();
}

class _ProductListingState extends State<ProductListing> {
  // product.documentId -> index of image to display
  HashMap activeImageMap = HashMap<String, int>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection(constants.DBCollections.products)
          .orderBy('created', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LinearProgressIndicator();
        }

        return _buildProductListingItems(
          context,
          snapshot.data.documents,
        );
      },
    );
  }

  Widget _buildProductListingItems(
    BuildContext context,
    List<DocumentSnapshot> snapshots,
  ) {
    List<Widget> widgets = List<Widget>();
    snapshots.asMap().forEach((index, data) {
      final product = Product.fromSnapshot(data);

      // If current signed in user is a customer and
      // the product is unpublished, then
      // don't show the product
      if (!(currentSignedInUser.role == RoleType.customer &&
          !product.isPublished)) {
        widgets.add(_buildProductListingItem(context, index, product));
      }
    });

    return ListView(
      key: Key(makeTestKeyString(
        TKUsers.admin,
        TKScreens.productListing,
        "list",
      )),
      children: widgets,
    );
  }

  Widget _buildProductListingItem(
    BuildContext context,
    int index,
    Product product,
  ) {
    activeImageMap.putIfAbsent(product.documentId, () => 0);

    return Container(
      padding: const EdgeInsets.only(
        left: 16.0,
        top: 16.0,
        right: 16.0,
      ),
      child: _buildProductListingItemTile(
        context,
        product,
        index,
      ),
    );
  }

  Widget _buildProductListingItemTile(
    BuildContext context,
    Product product,
    int index,
  ) {
    var pageController = PageController(viewportFraction: 1.0);

    var widgetList = <Widget>[
      _buildProductListingItemTileImage(product, pageController),
    ];

    if ((product.imageUrls?.length ?? 0) > 1) {
      widgetList.add(
        _buildProductListingImageSliderButtons(product, pageController),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Stack(
          alignment: AlignmentDirectional.center,
          children: widgetList,
        ),
        _buildProductListingItemTileInfoPane(product),
      ],
    );
  }

  Widget _buildProductListingImageSliderButtons(
    Product product,
    PageController pageController,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        activeImageMap[product.documentId] == 0
            ? Container()
            : _buildProductListingImageLeftButton(product, pageController),
        activeImageMap[product.documentId] == product.imageUrls.length - 1
            ? Container()
            : _buildProductListingImageRightButton(product, pageController),
      ],
    );
  }

  Widget _buildProductListingImageRightButton(
    Product product,
    PageController pageController,
  ) {
    return IconButton(
      icon: buildIconWithShadow(Icons.chevron_right),
      onPressed: () {
        pageController.nextPage(
          duration: Duration(milliseconds: 500),
          curve: Curves.ease,
        );
      },
    );
  }

  Widget _buildProductListingImageLeftButton(
    Product product,
    PageController pageController,
  ) {
    return IconButton(
      icon: buildIconWithShadow(Icons.chevron_left),
      onPressed: () {
        pageController.previousPage(
          duration: Duration(milliseconds: 500),
          curve: Curves.ease,
        );
      },
    );
  }

  Widget _buildProductListingItemTileInfoPane(Product product) {
    return GestureDetector(
      key: Key(makeTestKeyString(
        TKUsers.admin,
        TKScreens.productListing,
        "infoPane_" + product.name,
      )),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              if (currentSignedInUser.isAdmin()) {
                return AdminProductDetailPage(
                  productDocumentId: product.documentId,
                );
              } else {
                return CustomerProductDetailPage(
                  productDocumentId: product.documentId,
                );
              }
            },
          ),
        );
      },
      child: _buildProductInfoPaneContents(product),
    );
  }

  Widget _buildProductInfoPaneContents(Product product) {
    return Container(
      padding: EdgeInsets.all(16.0),
      color: kPaletteWhite,
      child: Column(
        children: <Widget>[
          _buildProductInfoPaneTitleRow(product),
          _buildProductInfoPaneDescriptionRow(product),
        ],
      ),
    );
  }

  Widget _buildProductInfoPaneDescriptionRow(Product product) {
    List<Widget> widgetList = <Widget>[
      _buildProductInfoPaneDescription(product),
    ];

    if (currentSignedInUser.isAdmin()) {
      widgetList.add(_buildProductInfoPaneEditButton(product));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: widgetList,
    );
  }

  Widget _buildProductInfoPaneTitleRow(Product product) {
    List<Widget> widgetList = <Widget>[
      _buildProductInfoPaneTitle(product),
    ];

    if (currentSignedInUser.isAdmin()) {
      widgetList.add(_buildProductInfoPanePublishSwitch(product));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: widgetList,
    );
  }

  Widget _buildProductInfoPaneEditButton(Product product) {
    return IconButton(
      icon: Icon(
        Icons.edit,
        color: paletteForegroundColor,
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminNewProductPage(
              productDocumentId: product.documentId,
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductInfoPaneDescription(Product product) {
    return Expanded(
      child: Text(
        product.description,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
        style: TextStyle(
          color: paletteBlackColor,
          fontSize: 16.0,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }

  Widget _buildProductInfoPanePublishSwitch(Product product) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Text(
          "公開する",
          style: TextStyle(
            color: paletteBlackColor,
            fontSize: 14.0,
            fontWeight: FontWeight.w300,
          ),
        ),
        Switch(
          value: product.isPublished,
          onChanged: (value) async {
            await Firestore.instance
                .collection(constants.DBCollections.products)
                .document(product.documentId)
                .updateData({'isPublished': value});
          },
          activeTrackColor: paletteForegroundColor,
          activeColor: kPaletteWhite,
        ),
      ],
    );
  }

  Widget _buildProductInfoPaneTitle(Product product) {
    var _padding = currentSignedInUser.isAdmin() ? 0.0 : 8.0;

    return Padding(
      padding: EdgeInsets.only(bottom: _padding),
      child: Text(
        product.name,
        key: Key(makeTestKeyString(
          TKUsers.admin,
          TKScreens.productListing,
          "title_" + product.name,
        )),
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: paletteBlackColor,
          fontWeight: FontWeight.w600,
          fontSize: 16.0,
        ),
      ),
    );
  }

  Widget _buildProductListingItemTileImage(
    Product product,
    PageController pageController,
  ) {
    return Container(
      color: const Color(0xFF8D8D8D),
      height: constants.imageHeight,
      width: 500,
      child: _getProductListingImage(product, pageController),
    );
  }

  Widget _getProductListingImage(
    Product product,
    PageController pageController,
  ) {
    var widgetList = <Widget>[];

    if (product.isPublished || (product.imageUrls?.length ?? 0) != 0) {
      widgetList.add(
        SpinKitThreeBounce(
          color: Colors.white,
          size: 16,
        ),
      );
    }

    widgetList.add(
      _buildProductImagePageView(pageController, product),
    );

    return Stack(
      alignment: AlignmentDirectional.center,
      children: widgetList,
    );
  }

  Widget _buildProductImagePageView(
    PageController pageController,
    Product product,
  ) {
    return PageView.builder(
      controller: pageController,
      itemCount: product.imageUrls.length,
      itemBuilder: (BuildContext context, int itemIndex) {
        return _getProductImage(product, itemIndex);
      },
      onPageChanged: (index) {
        setState(() {
          activeImageMap[product.documentId] = index;
        });
      },
    );
  }

  Widget _getProductImage(Product product, int imageIndex) {
    if (product.imageUrls?.isEmpty ?? true) {
      return Image.memory(
        kTransparentImage,
        height: constants.imageHeight,
      );
    } else {
      return FadeInImage.memoryNetwork(
        fit: BoxFit.fill,
        placeholder: kTransparentImage,
        image: product.imageUrls[imageIndex],
      );
    }
  }
}