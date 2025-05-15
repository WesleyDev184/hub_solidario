import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/app/applicants/presentation/widgets/applicants_card.dart';
import 'package:project_rotary/core/components/appbar_custom.dart';
import 'package:project_rotary/core/components/bottom_navigation.dart';
import 'package:project_rotary/core/components/input_field.dart';
import 'package:project_rotary/core/theme/custom_colors.dart';

class ApplicantsPage extends StatefulWidget {
  const ApplicantsPage({super.key});

  @override
  State<ApplicantsPage> createState() => _ApplicantsPageState();
}

class _ApplicantsPageState extends State<ApplicantsPage> {
  final TextEditingController searchController = TextEditingController();

  final List<Map<String, dynamic>> applicantsData = [
    {
      "id": "1",
      "imageUrl": "assets/images/cr.jpg",
      "title": "João Silva",
      "available": 10,
      "beneficiary": true,
    },
    {
      "id": "2",
      "title": "Maria Oliveira",
      "available": 5,
      "beneficiary": false,
    },
    {
      "id": "3",
      "imageUrl": "assets/images/cr.jpg",
      "title": "Carlos Souza",
      "available": 8,
      "beneficiary": true,
    },
    {
      "id": "4",
      "imageUrl": "assets/images/cr.jpg",
      "title": "Ana Paula",
      "available": 12,
      "beneficiary": false,
    },
    {
      "id": "5",
      "imageUrl": "assets/images/cr.jpg",
      "title": "Roberto Lima",
      "available": 7,
      "beneficiary": true,
    },
    {
      "id": "6",
      "imageUrl": "assets/images/cr.jpg",
      "title": "Fernanda Costa",
      "available": 9,
      "beneficiary": false,
    },
    {"id": "7", "title": "Lucas Pereira", "available": 6, "beneficiary": true},
    {
      "id": "8",
      "imageUrl": "assets/images/cr.jpg",
      "title": "Camila Santos",
      "available": 11,
      "beneficiary": false,
    },
    {
      "id": "9",
      "imageUrl": "assets/images/cr.jpg",
      "title": "Bruno Carvalho",
      "available": 4,
      "beneficiary": true,
    },
    {
      "id": "10",
      "imageUrl": "assets/images/cr.jpg",
      "title": "Patrícia Almeida",
      "available": 15,
      "beneficiary": false,
    },
  ];

  List<Map<String, dynamic>> filteredApplicants = [];

  @override
  void initState() {
    super.initState();
    filteredApplicants = List.from(applicantsData);
    searchController.addListener(filterApplicants);
  }

  void filterApplicants() {
    final query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredApplicants = List.from(applicantsData);
      } else {
        filteredApplicants =
            applicantsData.where((category) {
              final title = category["title"].toString().toLowerCase();
              return title.contains(query);
            }).toList();
      }
    });
  }

  @override
  void dispose() {
    searchController.removeListener(filterApplicants);
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CustomColors.white,
        image: DecorationImage(
          image: const AssetImage("assets/images/bg.jpg"),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            CustomColors.primarySwatch.shade100,
            BlendMode.dstATop,
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBarCustom(title: 'Solicitantes', saveAction: () {}),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              InputField(
                controller: searchController,
                hint: "Buscar",
                icon: LucideIcons.search,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.vertical, // define a direção vertical
                  physics: const BouncingScrollPhysics(),
                  itemCount: filteredApplicants.length,
                  itemBuilder: (context, index) {
                    final applicant = filteredApplicants[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 5.0),
                      child: ApplicantsCard(
                        id: applicant["id"] as String,
                        imageUrl: applicant["imageUrl"] as String?,
                        name: applicant["title"] as String,
                        qtd: applicant["available"] as int,
                        beneficiary: applicant["beneficiary"] ?? false,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigation(),
      ),
    );
  }
}
