// lib/data/lab_data.dart

import 'package:flutter_to_do_list/model/lab_model.dart';
import 'package:flutter/material.dart';

final List<Lab> labList = [
  Lab(
    name: "Thyrocare, Coimbatore",
    domain: "Thyroid Testing",
    about: "Thyrocare provides comprehensive thyroid testing services, including blood tests for thyroid hormone levels.",
    benefits: [
      "Accurate thyroid hormone level analysis",
      "Early detection of thyroid disorders",
      "Convenient sample collection"
    ],
    faqs: [
      {"question": "What is Thyroid Testing?", "answer": "Thyroid testing measures thyroid hormone levels in the blood to diagnose thyroid disorders."},
      {"question": "How do I prepare for the test?", "answer": "Avoid eating or drinking anything except water for 8-12 hours before the test."},
    ],
    icon: Icon(Icons.science),  // Using Icon here
  ),
  Lab(
    name: "Aarthi Scans, Coimbatore",
    domain: "Diagnostic Imaging",
    about: "Aarthi Scans offers advanced diagnostic imaging services, including MRI and CT scans.",
    benefits: [
      "High-resolution imaging",
      "Non-invasive diagnostics",
      "Fast and accurate results"
    ],
    faqs: [
      {"question": "What types of scans are available?", "answer": "We offer MRI, CT scans, X-rays, and ultrasound imaging."},
      {"question": "How long does an MRI take?", "answer": "An MRI scan typically takes between 30 to 60 minutes, depending on the area being scanned."},
    ],
    icon: Icon(Icons.science),  // Using Icon here
  ),
  Lab(
    name: "Vijaya Pathology Labs",
    domain: "Pathology",
    about: "Vijaya Labs provides accurate and timely pathology services for all types of blood and tissue testing.",
    benefits: [
      "Accurate diagnosis",
      "Fast reporting",
      "Experienced pathologists"
    ],
    faqs: [
      {"question": "What tests are available?", "answer": "Blood tests, biopsy, and cytology tests."},
      {"question": "How soon will I get results?", "answer": "Most test results are available within 24 hours."},
    ],
    icon: Icon(Icons.bloodtype),
  ),
  Lab(
    name: "Apollo Health Check, Coimbatore",
    domain: "Preventive Health",
    about: "Apollo Health Check specializes in comprehensive health checkups and preventive screenings.",
    benefits: [
      "Comprehensive health packages",
      "Early detection of diseases",
      "Affordable pricing"
    ],
    faqs: [
      {"question": "What does a full-body check include?", "answer": "It includes blood tests, ECG, and general health assessment."},
      {"question": "How often should I get a health check?", "answer": "It’s recommended to get a checkup annually."},
    ],
    icon: Icon(Icons.health_and_safety),
  ),
  Lab(
    name: "Dr. Lal PathLabs",
    domain: "Blood Testing",
    about: "Specialists in all kinds of blood tests and diagnostic services, including hematology and biochemistry.",
    benefits: [
      "State-of-the-art equipment",
      "Wide range of tests",
      "Home sample collection"
    ],
    faqs: [
      {"question": "Is fasting required for blood tests?", "answer": "For some tests like glucose or cholesterol, fasting is required."},
      {"question": "Can I book a test online?", "answer": "Yes, tests can be booked through our website."},
    ],
    icon: Icon(Icons.opacity),
  ),
  Lab(
    name: "Sri Ramakrishna Hospital Labs",
    domain: "Genetic Testing",
    about: "Offering a wide range of genetic tests to identify hereditary conditions and health risks.",
    benefits: [
      "Comprehensive genetic analysis",
      "Personalized reports",
      "Cutting-edge technology"
    ],
    faqs: [
      {"question": "What is genetic testing?", "answer": "It analyzes DNA to detect genetic conditions or risks."},
      {"question": "How accurate are genetic tests?", "answer": "Our tests are highly accurate with advanced technology."},
    ],
    icon: Icon(Icons.image),
  ),
  Lab(
    name: "Lotus Labs",
    domain: "Radiology",
    about: "Lotus Labs provides high-quality radiology services, including X-rays and ultrasounds.",
    benefits: [
      "Advanced X-ray equipment",
      "Accurate ultrasound imaging",
      "Quick report turnaround"
    ],
    faqs: [
      {"question": "What areas do you scan?", "answer": "We scan all body parts including chest, abdomen, and limbs."},
      {"question": "Is radiation exposure safe?", "answer": "Yes, we use low-dose techniques for safety."},
    ],
    icon: Icon(Icons.waves),
  ),
  Lab(
    name: "Sree Diagnostics",
    domain: "Cardiac Testing",
    about: "Specialized in cardiac diagnostics, offering ECG, ECHO, and stress tests for heart health assessment.",
    benefits: [
      "Accurate cardiac diagnostics",
      "Non-invasive procedures",
      "Experienced cardiologists"
    ],
    faqs: [
      {"question": "What tests do you offer?", "answer": "ECG, ECHO, and treadmill stress tests."},
      {"question": "How soon will I get my results?", "answer": "Most cardiac test results are provided within 2 hours."},
    ],
    icon: Icon(Icons.favorite),
  ),
  Lab(
    name: "Thyrocare Labs",
    domain: "Thyroid Testing",
    about: "Expert in thyroid testing, offering T3, T4, and TSH testing for thyroid function evaluation.",
    benefits: [
      "Accurate thyroid function tests",
      "Fast results",
      "Affordable pricing"
    ],
    faqs: [
      {"question": "How are thyroid tests performed?", "answer": "We perform simple blood tests to check thyroid hormone levels."},
      {"question": "How soon are results available?", "answer": "Results are typically ready within 6 hours."},
    ],
    icon: Icon(Icons.thermostat),
  ),
  Lab(
    name: "Skin & Allergy Labs",
    domain: "Allergy Testing",
    about: "Specializing in allergy testing for food, environmental, and skin allergies.",
    benefits: [
      "Comprehensive allergy panels",
      "Skin patch testing",
      "Detailed allergy reports"
    ],
    faqs: [
      {"question": "What allergens can be tested?", "answer": "We test for food, pollen, dust mites, and more."},
      {"question": "How long does the test take?", "answer": "The patch test takes about 20 minutes."},
    ],
    icon: Icon(Icons.water_drop_outlined)
  ),
  Lab(
    name: "Vasan Eye Care Labs",
    domain: "Ophthalmology",
    about: "Providing advanced diagnostic eye testing services for a variety of vision and eye health concerns.",
    benefits: [
      "Accurate eye diagnostics",
      "Comprehensive eye health reports",
      "Experienced ophthalmologists"
    ],
    faqs: [
      {"question": "What tests do you offer?", "answer": "We offer eye exams, vision tests, and glaucoma screening."},
      {"question": "Do you offer laser eye treatment?", "answer": "Yes, we provide laser treatments for vision correction."},
    ],
    icon: Icon(Icons.remove_red_eye),
  ),
  Lab(
    name: "Prime Diagnostics, Coimbatore",
    domain: "Molecular Biology",
    about: "Prime Diagnostics offers cutting-edge molecular biology tests for infectious diseases and genetic disorders.",
    benefits: [
      "Advanced molecular techniques",
      "Accurate diagnosis",
      "Quick turnaround time"
    ],
    faqs: [
      {"question": "What molecular tests do you offer?", "answer": "We offer PCR, RT-PCR, and DNA sequencing."},
      {"question": "How soon are results available?", "answer": "Results are typically ready within 24 to 48 hours."},
    ],
    icon: Icon(Icons.biotech),
  ),
  Lab(
    name: "HealthFirst Labs",
    domain: "Diabetes Management",
    about: "HealthFirst specializes in diagnostic services for diabetes, offering regular monitoring and HbA1c testing.",
    benefits: [
      "Comprehensive diabetes testing",
      "HbA1c monitoring",
      "Diet and lifestyle advice"
    ],
    faqs: [
      {"question": "How is diabetes diagnosed?", "answer": "We offer blood glucose testing, including fasting and postprandial tests."},
      {"question": "How often should I test my HbA1c?", "answer": "It's recommended to test every 3 months."},
    ],
    icon: Icon(Icons.timeline),
  ),
  Lab(
    name: "Medivision Diagnostics",
    domain: "Prenatal Testing",
    about: "Offering comprehensive prenatal testing services, including ultrasounds and non-invasive prenatal screening (NIPT).",
    benefits: [
      "Safe and non-invasive",
      "Accurate prenatal screening",
      "Early detection of fetal conditions"
    ],
    faqs: [
      {"question": "What is NIPT?", "answer": "Non-Invasive Prenatal Testing analyzes fetal DNA in the mother’s blood."},
      {"question": "When should prenatal tests be done?", "answer": "NIPT is usually done after the 10th week of pregnancy."},
    ],
    icon: Icon(Icons.pregnant_woman),
  ),
  Lab(
    name: "EcoHealth Labs",
    domain: "Environmental Health Testing",
    about: "Specialized in environmental testing, analyzing air, water, and soil quality for pollutants and toxins.",
    benefits: [
      "Comprehensive environmental testing",
      "Certified laboratory standards",
      "Fast and reliable results"
    ],
    faqs: [
      {"question": "What pollutants do you test for?", "answer": "We test for heavy metals, bacteria, and chemical contaminants."},
      {"question": "Can I get water quality tested?", "answer": "Yes, we offer full water quality testing."},
    ],
    icon: Icon(Icons.eco),
  ),
  Lab(
    name: "Sunrise Imaging Labs",
    domain: "Breast Imaging",
    about: "Providing state-of-the-art breast imaging services, including mammograms and breast ultrasounds for early cancer detection.",
    benefits: [
      "High-resolution mammography",
      "Early detection of breast cancer",
      "Safe and painless procedures"
    ],
    faqs: [
      {"question": "How often should I get a mammogram?", "answer": "Women over 40 should have a mammogram annually."},
      {"question": "Is the procedure painful?", "answer": "Mammograms are generally painless, though some discomfort may occur."},
    ],
    icon: Icon(Icons.family_restroom_outlined),
  ),
  Lab(
    name: "NeuroCare Diagnostics",
    domain: "Neurology Testing",
    about: "NeuroCare Diagnostics offers specialized tests such as EEG, EMG, and nerve conduction studies to assess brain and nerve function.",
    benefits: [
      "Accurate neurological assessments",
      "Non-invasive tests",
      "Expert neurologists"
    ],
    faqs: [
      {"question": "What is an EEG?", "answer": "An EEG measures electrical activity in the brain to detect abnormalities."},
      {"question": "What is a nerve conduction study?", "answer": "It tests how well and how fast nerves send electrical signals."},
    ],
    icon: Icon(Icons.psychology),
  ),
  Lab(
    name: "Digestive Health Labs",
    domain: "Gastroenterology",
    about: "Specialized in digestive health diagnostics, offering endoscopy, colonoscopy, and stool testing.",
    benefits: [
      "Comprehensive gastro diagnostics",
      "Modern endoscopy equipment",
      "Detailed digestive health reports"
    ],
    faqs: [
      {"question": "What is an endoscopy?", "answer": "It’s a procedure to examine the digestive tract using a small camera."},
      {"question": "What conditions can you diagnose?", "answer": "We diagnose ulcers, GERD, and colorectal conditions."},
    ],
    icon: Icon(Icons.restaurant),
  ),
  Lab(
    name: "Pediatric Diagnostics",
    domain: "Pediatrics",
    about: "Offering a wide range of pediatric diagnostic services for infants and children, including developmental assessments and vaccinations.",
    benefits: [
      "Child-friendly diagnostic services",
      "Vaccinations and health checkups",
      "Pediatric specialists"
    ],
    faqs: [
      {"question": "Do you offer vaccinations?", "answer": "Yes, we offer all routine vaccinations for children."},
      {"question": "How often should children have checkups?", "answer": "We recommend annual checkups for children."},
    ],
    icon: Icon(Icons.child_care),
  ),
  Lab(
    name: "SleepWell Labs",
    domain: "Sleep Studies",
    about: "SleepWell Labs offers diagnostic services for sleep disorders, including sleep apnea and insomnia testing.",
    benefits: [
      "Comprehensive sleep studies",
      "Diagnosis of sleep disorders",
      "Comfortable testing environment"
    ],
    faqs: [
      {"question": "What is a sleep study?", "answer": "It monitors sleep patterns to diagnose sleep disorders like sleep apnea."},
      {"question": "How long is the sleep test?", "answer": "It typically lasts overnight."},
    ],
    icon: Icon(Icons.nights_stay),
  ),
  Lab(
    name: "HeartCare Labs",
    domain: "Cardiac Imaging",
    about: "Specializing in cardiac imaging, HeartCare Labs offers ECHO, cardiac MRI, and stress tests for comprehensive heart health assessment.",
    benefits: [
      "Advanced cardiac imaging",
      "Experienced cardiologists",
      "Early detection of heart diseases"
    ],
    faqs: [
      {"question": "What is an ECHO?", "answer": "Echocardiogram uses sound waves to create images of the heart."},
      {"question": "How often should I have a cardiac test?", "answer": "It depends on your risk factors; consult with your doctor."},
    ],
    icon: Icon(Icons.favorite_border),
  ),
];