import 'dart:convert';

Sevengeemodel sevengeemodelFromJson(String str) =>
    Sevengeemodel.fromJson(json.decode(str));
String sevengeemodelToJson(Sevengeemodel data) => json.encode(data.toJson());

class Sevengeemodel {
  List<dynamic> steps;
  List<dynamic> backgrounds;
  List<dynamic> bespokes;
  int total_bespoke;
  Questions questions;

  Sevengeemodel({
    required this.steps,
    required this.backgrounds,
    required this.bespokes,
    required this.total_bespoke,
    required this.questions,
  });

  // ✅ Empty factory constructor
  factory Sevengeemodel.empty() {
    return Sevengeemodel(
      steps: [],
      backgrounds: [],
      bespokes: [],
      total_bespoke: 0,
      questions: Questions.empty(),
    );
  }

  factory Sevengeemodel.fromJson(Map<String, dynamic> json) {
    return Sevengeemodel(
      steps: json['steps'] ?? [],
      backgrounds: json['backgrounds'] ?? [],
      bespokes: json['bespokes'] ?? [],
      total_bespoke: json['total_bespoke'] ?? 0,
      questions: json['questions'] != null 
          ? Questions.fromJson(json['questions']) 
          : Questions.empty(),
    );
  }

  Map<String, dynamic> toJson() => {
        'steps': steps,
        'backgrounds': backgrounds,
        'bespokes': bespokes,
        'total_bespoke': total_bespoke,
        'questions': questions.toJson(),
      };
}

// Also update the Questions class if you haven't already
class Questions {
  dynamic step1;
  dynamic step2;
  dynamic step3;
  dynamic step4;
  dynamic step5;
  dynamic step6;
  dynamic step7;

  Questions({
    this.step1,
    this.step2,
    this.step3,
    this.step4,
    this.step5,
    this.step6,
    this.step7,
  });

  // ✅ Empty factory constructor for Questions
  factory Questions.empty() {
    return Questions(
      step1: '',
      step2: '',
      step3: '',
      step4: '',
      step5: '',
      step6: '',
      step7: '',
    );
  }

  factory Questions.fromJson(Map<String, dynamic> json) {
    return Questions(
      step1: json['step1'],
      step2: json['step2'],
      step3: json['step3'],
      step4: json['step4'],
      step5: json['step5'],
      step6: json['step6'],
      step7: json['step7'],
    );
  }

  Map<String, dynamic> toJson() => {
        'step1': step1,
        'step2': step2,
        'step3': step3,
        'step4': step4,
        'step5': step5,
        'step6': step6,
        'step7': step7,
      };
}

