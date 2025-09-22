import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: SafeArea(
          bottom: false,
          child: Container(
            color: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.search, color: Colors.grey),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text('Tìm kiếm sản phẩm, thương hiệu,...', overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.photo_camera_outlined, color: Colors.white),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Thoát', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _SectionTitle(icon: Icons.trending_up, title: 'Từ khóa tìm kiếm nhiều'),
          SizedBox(height: 8),
          _KeywordGrid(),
          SizedBox(height: 16),
          _SectionTitle(icon: Icons.article_outlined, title: 'Danh mục tìm kiếm nhiều'),
          SizedBox(height: 8),
          _CategoryPairs(),
          SizedBox(height: 16),
          _SectionTitle(icon: Icons.loyalty_outlined, title: 'Thương hiệu tìm kiếm nhiều'),
          SizedBox(height: 8),
          _BrandRow(),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _KeywordGrid extends StatelessWidget {
  const _KeywordGrid();

  @override
  Widget build(BuildContext context) {
    final items = [
      _KeywordItem('Kirkland'),
      _KeywordItem('murad'),
      _KeywordItem('Doppelherz'),
      _KeywordItem('Popper'),
      _KeywordItem('collagen'),
      _KeywordItem('âm đạo'),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 72,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemBuilder: (context, i) => items[i],
    );
  }
}

class _KeywordItem extends StatelessWidget {
  final String title;
  const _KeywordItem(this.title);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F9),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.image, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}

class _CategoryPairs extends StatelessWidget {
  const _CategoryPairs();

  @override
  Widget build(BuildContext context) {
    final rows = const [
      ['Thực phẩm - Hàng tiêu dùng', 'Vitamin Làm Đẹp Da'],
      ['Bổ trợ xương khớp', 'Ginkgo Biloba'],
      ['Quà tặng Valentine', 'Glucosamine'],
      ['Chăm sóc cơ thể', 'Bổ mắt'],
    ];
    return Column(
      children: [
        for (final r in rows)
          Row(
            children: [
              Expanded(child: _CategoryCell(title: r[0])),
              const SizedBox(width: 12),
              Expanded(child: _CategoryCell(title: r[1])),
            ],
          ),
      ],
    );
  }
}

class _CategoryCell extends StatelessWidget {
  final String title;
  const _CategoryCell({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.image, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title, maxLines: 2)),
        ],
      ),
    );
  }
}

class _BrandRow extends StatelessWidget {
  const _BrandRow();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      runSpacing: 16,
      children: List.generate(
        6,
        (index) => Container(
          width: (MediaQuery.of(context).size.width - 16 * 2 - 16 * 2) / 3,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE3E6EC)),
          ),
          child: const Icon(Icons.image, color: Colors.grey),
        ),
      ),
    );
  }
}


