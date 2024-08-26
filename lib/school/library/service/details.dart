import 'dart:collection';

import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:dio/dio.dart';
import 'package:mimir/init.dart';

import 'package:mimir/session/library.dart';

import '../api.dart';
import '../entity/book.dart';

class BookDetailsService {
  LibrarySession get session => Init.librarySession;

  const BookDetailsService();

  Future<BookDetails> query(String bookId) async {
    final response = await session.request(
      '${LibraryApi.bookUrl}/$bookId',
      options: Options(
        method: "GET",
      ),
    );
    final html = BeautifulSoup(response.data);
    final detailItems = html
        .find('table', id: 'bookInfoTable')!
        .findAll('tr')
        .map(
          (e) => e
              .findAll('td')
              .map(
                (e) => e.text.replaceAll(RegExp(r'\s*'), ''),
              )
              .toList(),
        )
        .where(
      (element) {
        if (element.isEmpty) {
          return false;
        }
        String e1 = element[0];

        // 过滤包含这些关键字的条目
        for (final keyword in ['分享', '相关', '随书']) {
          if (e1.contains(keyword)) return false;
        }

        return true;
      },
    ).toList();

    final rawDetails = LinkedHashMap.fromEntries(
      detailItems.sublist(1).map(
            (e) => MapEntry(
              e[0].substring(0, e[0].length - 1),
              e[1],
            ),
          ),
    );
    return parseBookDetails(rawDetails);
  }

  BookDetails parseBookDetails(Map<String, String> details) {
    final isbnAndPrice = details['ISBN']!.split('价格：');
    details["ISBN"] = isbnAndPrice[0];
    final price = isbnAndPrice.elementAtOrNull(1);
    if (price != null) {
      details["价格"] = price;
    }

    final classAndEdition = details['中图分类法']!.split('版次：');
    details["中图分类法"] = classAndEdition[0];
    if (classAndEdition.length > 1) {
      details["版次"] = classAndEdition[1];
    }

    return BookDetails(
      details: details,
    );
  }
}
