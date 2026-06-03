import 'package:flutter/material.dart';
import '../core/database/local_database.dart';
import '../core/theme/app_theme.dart';
import '../models/bus_model.dart';
import '../widgets/bus_unit_card.dart';

class BusesScreen extends StatefulWidget {
  const BusesScreen({super.key});

  @override
  State<BusesScreen> createState() => _BusesScreenState();
}

class _BusesScreenState extends State<BusesScreen> {
  List<BusModel> _allBuses = [];
  List<BusModel> _filteredBuses = [];
  String _selectedFilter = 'Todas las Unidades';
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBuses();
  }

  Future<void> _loadBuses() async {
    try {
      final dbData = await LocalDatabase.instance.getBuses();
      setState(() {
        _allBuses = dbData.map((map) => BusModel.fromDbMap(map)).toList();
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading buses: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      var result = _allBuses;

      // Filter by Search Query (Number or Model)
      if (_searchQuery.isNotEmpty) {
        result = result
            .where((bus) =>
                bus.number.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                bus.model.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();
      }

      // Filter by Category Tab selection
      if (_selectedFilter == 'Disponibles') {
        result = result.where((bus) => bus.isEnServicio).toList();
      } else if (_selectedFilter == 'En Mantenimiento') {
        result = result.where((bus) => !bus.isEnServicio).toList();
      }

      _filteredBuses = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Custom AppBar Header
                  Padding(
                    padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: const BoxDecoration(
                                color: AppTheme.surfaceContainer,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.menu, color: AppTheme.onBackgroundColor),
                                onPressed: () {},
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              'Unidades Disponibles',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.4,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.borderVariantColor.withOpacity(0.3),
                              width: 1.0,
                            ),
                            image: const DecorationImage(
                              image: NetworkImage(
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuBYWVZyhzmuT3XnSb3UR4urlHPLCPr18MIYPkGz9bwUFVPbCENoY31O5ZbhbeuT5iLLw1ZuPiGthmTU4K_2CS2WPzWjHssoyd2bJlZa0Ub96OjVJnL2MfXL6L4UBYUtF_JmS6UNtfVZUmxYW6UWP8Oq_VmwwNCuyDw5dQNFd28BVrRDgPCRiNykgB_iZQDTLe05yigOovx7CxKCc13P6MMVxaqZBB7adOJsPAiARcYKUeAHao8Yn1DxSGCC1L56pgcJJHDt4WCqJ7Ar',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Search bar & Filter Tabs Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Column(
                      children: [
                        Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              const Icon(Icons.search, color: AppTheme.secondaryColor),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  onChanged: (val) {
                                    _searchQuery = val;
                                    _applyFilters();
                                  },
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Buscar unidad por número...',
                                    hintStyle: TextStyle(
                                      color: AppTheme.secondaryColor,
                                      fontSize: 15,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Filter Tabs list
                        SizedBox(
                          height: 38,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _buildFilterTab('Todas las Unidades'),
                              const SizedBox(width: 8),
                              _buildFilterTab('Disponibles'),
                              const SizedBox(width: 8),
                              _buildFilterTab('En Mantenimiento'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Units Cards List
                  Expanded(
                    child: _filteredBuses.isEmpty
                        ? const Center(
                            child: Text(
                              'No se encontraron unidades',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppTheme.secondaryColor,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 100),
                            itemCount: _filteredBuses.length,
                            itemBuilder: (context, index) {
                              return BusUnitCard(bus: _filteredBuses[index]);
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildFilterTab(String label) {
    final bool isActive = label == _selectedFilter;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = label;
          _applyFilters();
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? AppTheme.primaryColor
                : AppTheme.borderVariantColor.withOpacity(0.3),
            width: 1.0,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : AppTheme.primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
