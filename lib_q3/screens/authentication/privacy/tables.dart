import 'package:flutter/material.dart';
import 'package:GapHub/utils/extensions.dart';

class Table1 extends StatelessWidget {
  const Table1({super.key});

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(),
      children: const [
        TableRow(
          children: [
            Tableheader(text: 'Type(s) of Data we use for this purpose'),
            Tableheader(text: 'Our lawful basis for processing this data'),
            Tableheader(text: 'Type(s) of Data we use for this purpose'),
          ],
        ),
        TableRow(
          children: [
            Tabletext(text: 'To register you as a customer to use our service'),
            Tabletext(
              text: 'Performance of a Contract with you (i.e. Contract)',
            ),
            Tabletext(text: 'Registration Information'),
          ],
        ),
        TableRow(
          children: [
            Tabletext(
              text:
                  'To manage our relationship with you (including notifying you about changes to our terms and conditions or this privacy policy)',
            ),
            Tabletext(text: 'Contract; Legal obligation'),
            Tabletext(text: 'Email address'),
          ],
        ),
        TableRow(
          children: [
            Tabletext(text: 'To understand our user base better'),
            Tabletext(
              text:
                  'To understand our user base better	Legitimate interests (to understand our user demographic and what users want to get out of our service)	Registration Information, Additional Personal Information',
            ),
            Tabletext(
              text: 'Registration Information, Additional Personal Information',
            ),
          ],
        ),
        TableRow(
          children: [
            Tabletext(text: 'Requesting your participation in online surveys'),
            Tabletext(text: 'Consent'),
            Tabletext(
              text:
                  'Customer Testimonials (we contact you to ask if you are happy for us to include your testimonial, and how you would like your name and/or social media handles to appear)',
            ),
          ],
        ),
        TableRow(
          children: [
            Tabletext(
              text: 'Posting customer testimonials and reviews on our website',
            ),
            Tabletext(text: 'Consent'),
            Tabletext(
              text:
                  'Customer Testimonials (we contact you to ask if you are happy for us to include your testimonial, and how you would like your name and/or social media handles to appear)',
            ),
          ],
        ),
        TableRow(
          children: [
            Tabletext(
              text:
                  'To tell you about goods or services (marketing material) that we feel may be of interest to you',
            ),
            Tabletext(text: 'Consent'),
            Tabletext(text: 'Email address'),
          ],
        ),
        TableRow(
          children: [
            Tabletext(
              text:
                  'To create your personal data record, which we need to uniquely identify you',
            ),
            Tabletext(text: 'Contract'),
            Tabletext(text: 'Unique User Reference'),
          ],
        ),
        TableRow(
          children: [
            Tabletext(text: 'To create your dashboard'),
            Tabletext(text: 'Contract'),
            Tabletext(
              text:
                  'Account and Transactional information, Custom Tags (if you have created these)',
            ),
          ],
        ),
        TableRow(
          children: [
            Tabletext(
              text:
                  'To provide user support and technical instructions regarding your account',
            ),
            Tabletext(text: 'Contract'),
            Tabletext(
              text:
                  'Registration information, Unique User Reference, Account and Transactional information and Technical information',
            ),
          ],
        ),
        TableRow(
          children: [
            Tabletext(text: 'To monitor and improve our service'),
            Tabletext(
              text:
                  'Legitimate interests (to track the use of our service and identify areas where we can improve service performance or service functionality. This includes business and technical improvements)',
            ),
            Tabletext(
              text:
                  'To monitor and improve our service	Legitimate interests (to track the use of our service and identify areas where we can improve service performance or service functionality. This includes business and technical improvements)	Registration information, Technical information, Additional Personal Information',
            ),
          ],
        ),
        TableRow(
          children: [
            Tabletext(
              text:
                  'To create aggregated market research, from which all personal data is removed',
            ),
            Tabletext(
              text:
                  'Legitimate interests (We sell this anonymised market research to clients to create the revenue we need to run our business and to provide you with a free service)',
            ),
            Tabletext(
              text:
                  'Account and Transactional information, Registration information',
            ),
          ],
        ),
        TableRow(
          children: [
            Tabletext(
              text:
                  'Use of necessary, functional and analytical cookies (see Cookies section for further information on specific purposes)',
            ),
            Tabletext(
              text: 'Legitimate interests (in operating our website); Consent',
            ),
            Tabletext(text: 'Technical information'),
          ],
        ),
        TableRow(
          children: [
            Tabletext(
              text:
                  'In pursuant to FCA registration;To maintain our statutory records to comply with our FCA requirements',
            ),
            Tabletext(text: 'Legal obligation'),
            Tabletext(text: 'Financial Services Records'),
          ],
        ),
      ],
    );
  }
}

class Tables2 extends StatelessWidget {
  const Tables2({super.key});

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(),
      children: const [
        TableRow(
          children: [
            Tableheader(text: 'Service provider'),
            Tableheader(
              text: 'Service provider	Description of service	Safeguards',
            ),
            Tableheader(text: 'Safeguards'),
          ],
        ),
        TableRow(
          children: [
            Tabletext(text: 'Plaid'),
            Tabletext(text: 'Credential sharing services'),
            Tabletext(text: 'EU-US Privacy Shield'),
          ],
        ),
        TableRow(
          children: [
            Tabletext(text: 'Sendinblue'),
            Tabletext(text: 'User Support tool'),
            Tabletext(text: 'GDPR'),
          ],
        ),
        TableRow(
          children: [
            Tabletext(text: 'Amazon Web Services (AWS)'),
            Tabletext(text: 'Infrastructure service'),
            Tabletext(text: 'EU-US Privacy Shield'),
          ],
        ),
        TableRow(
          children: [
            Tabletext(text: 'Sendinblue'),
            Tabletext(text: 'Marketing service'),
            Tabletext(text: 'GDPR'),
          ],
        ),
        TableRow(
          children: [
            Tabletext(text: 'Hubspot'),
            Tabletext(text: 'Marketing service'),
            Tabletext(text: 'EU-US Privacy Shield'),
          ],
        ),
        TableRow(
          children: [
            Tabletext(text: 'Twitter'),
            Tabletext(
              text:
                  'Social media (only if you choose to provide personal data)',
            ),
            Tabletext(text: 'EU-US Privacy Shield'),
          ],
        ),
        TableRow(
          children: [
            Tabletext(text: 'Facebook'),
            Tabletext(
              text:
                  'Social media (only if you choose to provide personal data)',
            ),
            Tabletext(text: 'EU-US Privacy Shield'),
          ],
        ),
        TableRow(
          children: [
            Tabletext(text: 'Instagram'),
            Tabletext(
              text:
                  'Social media (only if you choose to provide personal data)',
            ),
            Tabletext(text: 'EU-US Privacy Shield'),
          ],
        ),
        TableRow(
          children: [
            Tabletext(text: 'LinkedIn'),
            Tabletext(
              text: 'Social media (only if you choose to link your accounts)',
            ),
            Tabletext(text: 'EU-US Privacy Shield'),
          ],
        ),
        TableRow(
          children: [
            Tabletext(text: 'Gmail'),
            Tabletext(text: 'Our email client for incoming email queries'),
            Tabletext(text: 'EU-US Privacy Shield'),
          ],
        ),
        TableRow(
          children: [
            Tabletext(text: 'Google Drive'),
            Tabletext(text: 'Internal document repository'),
            Tabletext(text: 'EU-US Privacy Shield'),
          ],
        ),
        TableRow(
          children: [
            Tabletext(text: 'Android (Google Play) Store'),
            Tabletext(text: 'App reviews'),
            Tabletext(text: 'EU-US Privacy Shield'),
          ],
        ),
        TableRow(
          children: [
            Tabletext(text: 'App Store'),
            Tabletext(text: 'App reviews'),
            Tabletext(text: 'EU-US Privacy Shield'),
          ],
        ),
        TableRow(
          children: [
            Tabletext(text: 'Fabric / Firebase'),
            Tabletext(text: 'System monitoring diagnostics'),
            Tabletext(text: 'EU-US Privacy Shield'),
          ],
        ),
      ],
    );
  }
}

class Table3 extends StatelessWidget {
  const Table3({super.key});

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(),
      children: const [
        TableRow(
          children: [
            Tableheader(text: 'Cookie'),
            Tableheader(text: 'Type'),
            Tableheader(text: 'Purpose'),
            Tableheader(text: 'More Information'),
          ],
        ),
        TableRow(
          children: [
            Tabletext(text: 'AWSALB'),
            Tabletext(text: 'Necessary'),
            Tabletext(
              text:
                  'Used by Amazon Web Services (AWS) to provide Load Balancing functionality',
            ),
            Tabletext(
              text:
                  'AWSALB	Necessary	Used by Amazon Web Services (AWS) to provide Load Balancing functionality	The AWS Load balancer distributes all the users across the servers that make up our infrastructure. When you first visit our website you will be allocated to one of those servers – this cookie remembers which server so all page requests are from the same server.',
            ),
          ],
        ),
        TableRow(
          children: [
            Tabletext(text: '_ga*, _gid*'),
            Tabletext(text: 'Analytics'),
            Tabletext(
              text:
                  '_ga*, _gid*	Analytics	Used by Google analytics to track page views and site performance	https://tinyurl.com/q3wz83z',
            ),
            Tabletext(text: 'https://tinyurl.com/q3wz83z'),
          ],
        ),
        TableRow(
          children: [
            Tabletext(text: 'Mdbmpt'),
            Tabletext(text: 'Functionality'),
            Tabletext(
              text:
                  'Used by MyGAPhub to remember your email, if you select that option on login',
            ),
            Tabletext(text: ''),
          ],
        ),
        TableRow(
          children: [
            Tabletext(text: '__RequestVerificationToken'),
            Tabletext(text: 'Necessary'),
            Tabletext(text: 'Used by the application to ensure secure login'),
            Tabletext(
              text:
                  'When a form (such as the login form) is submitted to our application, we have to make sure that it has been submitted from the correct place (i.e. our application). This cookie ensures this and protects against “fake” form submissions and login attempts.',
            ),
          ],
        ),
        TableRow(
          children: [
            Tabletext(text: 'JSESSIONID'),
            Tabletext(text: 'Necessary'),
            Tabletext(
              text:
                  'Used by the application to remember your current logged in “session”.',
            ),
            Tabletext(
              text:
                  'Everytime you load a page on the application, we have to check that you are logged in correctly. This is called the “session” – the period between logging in and logging out. This cookie remembers if you are logged in and allows us to only present data / pages to you that are private.',
            ),
          ],
        ),
        TableRow(
          children: [
            Tabletext(text: 'mdb-authentication'),
            Tabletext(text: 'Necessary'),
            Tabletext(text: 'Used by MyGAPhub to ensure you are logged in'),
            Tabletext(text: ''),
          ],
        ),
        TableRow(
          children: [
            Tabletext(text: '_bs'),
            Tabletext(text: 'Analytics'),
            Tabletext(
              text: 'Used by the BlueShift marketing tool to track pageviews',
            ),
            Tabletext(text: ''),
          ],
        ),
        TableRow(
          children: [
            Tabletext(text: '*_sendinblue'),
            Tabletext(text: 'Analytics/Targeting'),
            Tabletext(
              text: 'Used by the Sendinblue marketing tool to track pageviews',
            ),
            Tabletext(text: ''),
          ],
        ),
        TableRow(
          children: [
            Tabletext(text: 'Fr'),
            Tabletext(text: 'Analytics'),
            Tabletext(text: 'Used by Facebook to track analytics'),
            Tabletext(text: ''),
          ],
        ),
        TableRow(
          children: [
            Tabletext(text: 'hasUser'),
            Tabletext(text: 'Functionality'),
            Tabletext(
              text: 'Used to track if the current visitor is a subscribed user',
            ),
            Tabletext(text: ''),
          ],
        ),
      ],
    );
  }
}

class Headers extends StatelessWidget {
  final String text;

  const Headers(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: context.width(.05),
      ),
    );
  }
}

class Tabletext extends StatelessWidget {
  const Tabletext({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(3.0), child: Text(text));
  }
}

class Tableheader extends StatelessWidget {
  const Tableheader({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: context.width(.04),
        ),
      ),
    );
  }
}
