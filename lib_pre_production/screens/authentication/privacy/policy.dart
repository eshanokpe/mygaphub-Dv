import 'package:GapHub/screens/authentication/privacy/tables.dart';
import 'package:GapHub/widgets/spaces.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:GapHub/utils/extensions.dart';
import 'package:url_launcher/url_launcher.dart';

class Policy extends StatefulWidget {
  const Policy({super.key});

  @override
  _PolicyState createState() => _PolicyState();
}

class _PolicyState extends State<Policy> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Privacy Policy".toUpperCase()),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.width(.02)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hspace(context.height(.02)),
              const Headers('Important information and who we are'),
              Hspace(context.height(.015)),
              const Text(
                'This is the Privacy Policy for “MyGAPhub”. MyGAPhub is a personal finance management platform, provided at www.mygaphub.com and associated mobile applications, that allows you to coordinate all aspects of your financial life in one place. You are able to plan (budgeting and strategy), execute your plan, access asset opportunities and manage your asset portfolio. All of this will help you control your financial life more efficiently (“the Service”).\n\nMyGAPhub is owned and operated by the PRISM Financial Technology Limited. Our company registration number is 12837226. Our registered office is at 20-22 Wenlock Road, London, England, N1 7GU.\n\nWhen we refer to our trading name “MyGAPhub” or “we”, “us” or “our” in this policy, we are referring to the PRISM Financial Technology Limited. We are the data ‘controller’ in relation to the personal data you provide to us, which means we determine the purposes and the way in which your personal data is, or will be, processed.',
                textAlign: TextAlign.justify,
              ),
              Hspace(context.height(.02)),
              const Headers('Purpose of this privacy policy'),
              Hspace(context.height(.015)),
              const Text(
                'This policy aims to give you information on how we collect and process any personal data we collect from you, or that you provide to us. We want you to be confident when you use our service that you know what your personal data is being used for, and that it is being kept safe.\n\nIt is important that you read this privacy policy together with any other privacy notice or fair processing notice we may provide on specific occasions when we are collecting or processing personal data about you, so that you are fully aware of how and why we are using your data. This privacy policy supplements the other notices and is not intended to override them.',
                textAlign: TextAlign.justify,
              ),
              Hspace(context.height(.02)),
              const Headers('How to contact us'),
              Hspace(context.height(.015)),
              const Text(
                "If there is anything you don’t understand or you’re not happy about, or if you just want to suggest improvements, please get in touch with us by:\n\nEmailing us at info@mygaphub.com\n\nWriting to the Executive Director, at 20-22 Wenlock Road, London, England, N1 7GU\n\nYou will always have the right to lodge a complaint with a supervisory body. The relevant authority in the UK is the Information Commissioner's Office. However, if you do have a complaint, we would appreciate the chance to deal with your concerns first, so please do contact us in the first instance.\n\nIf you have an unresolved privacy or data use concern that we have not addressed satisfactorily, you can also contact our U.S.-based third party dispute resolution provider (free of charge) at https://feedback-form.truste.com/watchdog/request.",
                textAlign: TextAlign.justify,
              ),
              Hspace(context.height(.02)),
              const Headers('How is your personal data collected?'),
              Hspace(context.height(.015)),
              const Text(
                'We use different methods to collect data from and about you including through:',
              ),
              Hspace(context.height(.015)),
              RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: context.width(.037),
                  ),
                  children: const [
                    TextSpan(
                      text: 'Direct interactions: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                          'You may give us your personal data by filling in forms or by corresponding with us in person, by email, by phone, by post or otherwise. This includes personal data you provide when registering to use our service.',
                    ),
                  ],
                ),
              ),
              Hspace(context.height(.015)),
              RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: context.width(.037),
                  ),
                  children: const [
                    TextSpan(
                      text: 'Automated technologies or interactions: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                          'As you interact with our website, we may automatically collect Technical data about your equipment, browsing actions and patterns. We collect this personal data by using cookies and other similar technologies. Please see below on Cookies for further information.',
                    ),
                  ],
                ),
              ),
              Hspace(context.height(.015)),
              RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: context.width(.037),
                  ),
                  children: const [
                    TextSpan(
                      text: 'Third parties or publicly available sources: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                          'We may receive personal data about you from various third parties and public sources, for example, analytics providers such as Google.',
                    ),
                  ],
                ),
              ),
              Hspace(context.height(.02)),
              const Headers('Information Which We May Collect'),
              Hspace(context.height(.02)),
              RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: context.width(.037),
                  ),
                  children: const [
                    TextSpan(
                      text: 'Registration Information: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                          'To register to use our service you will have to supply us with your email address, UK postcode and date of birth. Registration information also includes the credentials you share with us to allow us to access your Account Information.',
                    ),
                  ],
                ),
              ),
              Hspace(context.height(.015)),
              RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: context.width(.037),
                  ),
                  children: const [
                    TextSpan(
                      text: 'Additional Personal Information: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                          'You may choose to submit additional personal information when you register for the service, for example your name, your preferred pronoun (he, she, zhe), annual salary range and financial goal.',
                    ),
                  ],
                ),
              ),
              Hspace(context.height(.015)),
              RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: context.width(.037),
                  ),
                  children: const [
                    TextSpan(
                      text: 'Unique user reference: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                          'This is a reference which we assign to you when you sign up to use our service, to create your own unique data record.',
                    ),
                  ],
                ),
              ),
              Hspace(context.height(.015)),
              RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: context.width(.037),
                  ),
                  children: const [
                    TextSpan(
                      text: 'Account and Transactional Information: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                          'When you ‘Add Accounts’ to our service, we may access, store and process your Account Information held by your account provider. Account Information includes, for example, your account details, account transaction information, account features and benefits and regular payments.',
                    ),
                  ],
                ),
              ),
              Hspace(context.height(.015)),
              RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: context.width(.037),
                  ),
                  children: const [
                    TextSpan(
                      text: 'Custom Tags: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                          'We will collect and save any custom tags that you may choose to create in order to describe your transactions within relevant dashboard.',
                    ),
                  ],
                ),
              ),
              Hspace(context.height(.015)),
              RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: context.width(.037),
                  ),
                  children: const [
                    TextSpan(
                      text: 'Technical Information: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                          'When you browse our website, we automatically collect some technical information about your visit to our website, including, but not limited to, information about the device you are using to access MyGAPhub (for example, mobile device or web), the IP address used to connect your computer to the internet, your browser type and version and your browser plug-in types and version.',
                    ),
                  ],
                ),
              ),
              Hspace(context.height(.015)),
              RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: context.width(.037),
                  ),
                  children: const [
                    TextSpan(
                      text: 'Customer Testimonials: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                          'This could include your name, social media handle and/or any testimonial, review or other comment on our products or services that you choose to provide to us.',
                    ),
                  ],
                ),
              ),
              Hspace(context.height(.015)),
              RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: context.width(.037),
                  ),
                  children: const [
                    TextSpan(
                      text: 'Financial Services Records: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                          'This is record-keeping information which we collect in order to meet our regulatory and statutory duties.',
                    ),
                  ],
                ),
              ),
              Hspace(context.height(.02)),
              const Headers('How we use your information'),
              Hspace(context.height(.015)),
              const Text(
                "•	Where we need to perform the contract, we are about to enter into or have entered into with you (i.e. when you sign up to our service).\n\n•	Where we have your prior consent to use your personal data (for example, where you have consented to receiving marketing).\n\n•	Where it is necessary for our legitimate interests (or those of a third party) and your interests and fundamental rights do not override those interests. We make sure we consider and balance any potential impact on you (both positive and negative) and your rights before we process your personal data for our legitimate interests. We do not use your personal data for activities where our interests are overridden by the impact on you (unless we have your consent or are otherwise required or permitted to by law). You can obtain further information about how we assess our legitimate interests against any potential impact on you in respect of specific activities by contacting us.\n\n•	Where we need to comply with a legal or regulatory obligation.\n\nWe have set out below, in a table format, a description of all the ways we plan to use your personal data, and which of the legal bases we rely on to do so. We have also identified what our legitimate interests are where appropriate.\n\nPlease note that we may process your personal data for more than one lawful ground depending on the specific purpose for which we are using your data. Please contact us if you need details about the specific legal ground we are relying on to process your personal data where more than one ground has been set out in the table below.",
                textAlign: TextAlign.justify,
              ),
              Hspace(context.height(.02)),
              const Table1(),
              Hspace(context.height(.015)),
              const Text(
                'You may control your subscriptions to any of the above marketing content notifications via the Settings feature of our service.',
                textAlign: TextAlign.justify,
              ),
              Hspace(context.height(.02)),
              const Headers(
                'Key people who have to be able to access your information',
              ),
              Hspace(context.height(.015)),
              const Text(
                'PRISMCHECK UK Limited. This company is our sister. It is a company registered in England and Wales, with number 06870607. We share information with our sister company for the sole purpose of providing you with our service. We ensure that our sister company treats your data in exactly the same way as we do.\n\nIf you connect your accounts to our service using credential sharing, we will use a company called Plaid (www.plaid.com) to do this. Plaid collects and securely stores the credentials you share, such as User name and password. This information is never stored by, or disclosed to, us. For further information on how Plaid keeps your information secure please visit https://plaid.com/legal/. Plaid are headquartered in the USA. They have provided account aggregation to top UK & USA financial institutions for more than 7 years. We have a contract with Plaid which requires them to meet the requirements of the Data Protection Act and General Data Protection Regulations in just the same way as it applies to us. ',
                textAlign: TextAlign.justify,
              ),
              Hspace(context.height(.02)),
              const Headers(
                'The information we may give to or share with somebody else',
              ),
              Hspace(context.height(.015)),
              const Text(
                'We may share your personal information in the following ways:\n\n•	To companies that provide services to help us operate the application and communicate with users. These companies are authorised to use your personal information only as necessary to provide these services to us, and via contractual agreements that establish their responsibilities to protect your data;\n\n•	to HMRC, regulators and other authorities or bodies who require reporting of processing activities in certain circumstances. This includes exchanging information with other companies and organisations for the purposes of fraud protection and credit risk reduction and when we believe in good faith that disclosure is necessary to protect our rights, protect your safety or the safety of others, or investigate fraud;\n\n•	To professional advisers, including lawyers, bankers, auditors and insurers who provide consultancy, banking, legal, insurance and accounting services.\n\n•	If MyGAPhub is involved in a merger, acquisition, or sale of all or a portion of its assets, you will be notified via email and/or prominent notice on our website of any change in ownership or uses of your personal information, as well as any choices you may have regarding your personal information;\n\n•	To any other third party with your prior agreement to do so, where such agreement will be recorded by us, and retained in line with our data retention policy, and include the purpose, frequency and duration of the information sharing;\n\n•	With our subsidiary and with Plaid, as detailed in the "Section Key people who have to be able to access your information"',
              ),
              Hspace(context.height(.02)),
              const Headers('International transfers'),
              Hspace(context.height(.015)),
              const Text(
                'If we transfer your personal data out of the EEA, we ensure a similar degree of protection is afforded to it by ensuring at least one of the following safeguards is implemented:',
                textAlign: TextAlign.justify,
              ),
              Hspace(context.height(.015)),
              RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  style: const TextStyle(color: Colors.black),
                  children: [
                    const TextSpan(
                      text:
                          '•	The country has been deemed to provide an adequate level of protection for personal data by the European Commission. For further details, see ',
                    ),
                    TextSpan(
                      text:
                          ' European Commission: Adequacy of the protection of personal data in non-EU countries.',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Theme.of(context).primaryColor,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => launch(
                          'https://ec.europa.eu/info/law/law-topic/data-protection/international-dimension-data-protection/adequacy-decisions_en',
                        ),
                    ),
                  ],
                ),
              ),
              Hspace(context.height(.015)),
              RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  style: const TextStyle(color: Colors.black),
                  children: [
                    const TextSpan(
                      text:
                          '•	If we use certain service providers based outwith the EEA, we may use specific contracts approved by the European Commission which give personal data the same protection it has in Europe. For further details, see ',
                    ),
                    TextSpan(
                      text:
                          'European Commission: Model contracts for the transfer of personal data to third countries.',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Theme.of(context).primaryColor,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => launch(
                          'https://ec.europa.eu/info/law/law-topic/data-protection/international-dimension-data-protection/standard-contractual-clauses-scc_en',
                        ),
                    ),
                  ],
                ),
              ),
              Hspace(context.height(.015)),
              RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  style: const TextStyle(color: Colors.black),
                  children: [
                    const TextSpan(
                      text:
                          '•	If we use providers based in the US, we may transfer data to them if they are part of the Privacy Shield which requires them to provide similar protection to personal data shared between the Europe and the US. For further details, see ',
                    ),
                    TextSpan(
                      text: 'European Commission: EU-US Privacy Shield.',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Theme.of(context).primaryColor,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => launch(
                          'https://ec.europa.eu/info/law/law-topic/data-protection/international-dimension-data-protection/eu-us-data-transfers_en',
                        ),
                    ),
                  ],
                ),
              ),
              Hspace(context.height(.015)),
              const Text(
                '•	In any other case, we will obtain your explicit consent before any transfer takes place.\n\nSome of our external third-party service providers are based outside the EEA so their processing of your personal data will involve a transfer of data outside the EEA. The table below sets out details of transfers to such third parties and the relevant safeguards.',
              ),
              Hspace(context.height(.02)),
              const Tables2(),
              Hspace(context.height(.02)),
              const Headers('Your rights'),
              const Text(
                'Under certain circumstances, you have the following rights under data protection laws in relation to your personal data:',
                textAlign: TextAlign.justify,
              ),
              Hspace(context.height(.015)),
              const Text(
                '•	Access to your information\n\n•	Request correction of your personal data\n\n•	Request deletion of your personal data\n\n•	Object to processing of your personal data\n\n•	Request restriction of processing your personal data\n\n•	Request transfer of your personal data\n\n•	Right to withdraw consent\n\n•	Right to review by an independent authority\n\nIf you wish to exercise any of the rights set out above, please contact us at info@mygaphub.com. You will not have to pay a fee to access your personal data (or to exercise any of the other rights). However, we may charge a reasonable fee if your request is clearly unfounded, repetitive or excessive. Alternatively, we may refuse to comply with your request in these circumstances.\n\nWe may need to request specific information from you to help us confirm your identity and ensure your right to access your personal data (or to exercise any of your other rights). This is a security measure to ensure that personal data is not disclosed to any person who has no right to receive it. We may also contact you to ask you for further information in relation to your request to speed up our response.\n\nWe try to respond to all legitimate requests within one month. Occasionally it may take us longer than a month if your request is particularly complex or you have made a number of requests. In this case, we will notify you and keep you updated.',
              ),
              Hspace(context.height(.02)),
              const Headers('Access to your information'),
              Hspace(context.height(.015)),
              const Text(
                'You have the right to ask for a copy of the information which we hold on you (commonly known as a ‘data subject access request’). This enables you to receive a copy of the personal data we hold about you and to check that we are lawfully processing it.',
                textAlign: TextAlign.justify,
              ),
              Hspace(context.height(.02)),
              const Headers('Correcting personal data'),
              Hspace(context.height(.015)),
              const Text(
                'You have the right to request that we correct personal data that we hold about you. This enables you to have any incomplete or inaccurate information we hold corrected, though we may need to verify the accuracy of the new data that you provide to us.',
                textAlign: TextAlign.justify,
              ),
              Hspace(context.height(.02)),
              const Headers('Deleting personal data'),
              Hspace(context.height(.015)),
              const Text(
                'You may ask us to delete or remove personal data where there is no good reason for us continuing to process it. This is more commonly known as the ‘right to be forgotten’. You also have the right to ask us to delete or remove your personal data where you have successfully exercised your right to object to processing (see below), where we may have processed your information unlawfully or where we are required to erase your personal data to comply with local law.\n\nPlease note, however, that we may not always be able to comply with your request to delete or remove personal data for specific legal reasons which will be notified to you, if applicable, at the time of your request.',
                textAlign: TextAlign.justify,
              ),
              Hspace(context.height(.02)),
              const Headers('Objecting to processing'),
              Hspace(context.height(.015)),
              const Text(
                'You have the right to stop us processing your personal data for direct marketing purposes. We will always inform you if we intend to use your personal data for such purposes, or if we intend to disclose your information to any third party for such purposes. You can usually exercise your right to prevent such marketing by checking certain boxes on the forms we use to collect your data. You can also exercise the right at any time by contacting us at info@mygaphub.com.\n\nYou may also object to us processing your personal data where we are relying on a legitimate interest (or those of a third party) and there is something about your particular situation which makes you want to object to processing on this ground as you feel it impacts on your fundamental rights and freedoms. In some cases, we may demonstrate that we have compelling legitimate grounds to process your information which override your rights and freedoms.',
                textAlign: TextAlign.justify,
              ),
              Hspace(context.height(.02)),
              const Headers('Restriction of processing'),
              Hspace(context.height(.015)),
              const Text(
                'This enables you to ask us to suspend the processing of your personal data in the following scenarios:\n\n•	If you want us to establish the data\'s accuracy;\n\n•	Where our use of the data is unlawful but you do not want us to erase it;\n\n•	Where you need us to hold the data even if we no longer require it as you need it to establish, exercise or defend legal claims; or\n\n•	You have objected to our use of your data but we need to verify whether we have overriding legitimate grounds to use it.',
              ),
              Hspace(context.height(.015)),
              Hspace(context.height(.02)),
              const Headers('Transferring your personal data'),
              Hspace(context.height(.015)),
              const Text(
                'In certain circumstances, you may request the transfer of your personal data to you or to a third party. We will provide to you, or a third party you have chosen, your personal data in a structured, commonly used, machine-readable format.\n\nPlease note that this right only applies to automated information which you initially provided consent for us to use or where we used the information to perform a contract with you.',
                textAlign: TextAlign.justify,
              ),
              Hspace(context.height(.02)),
              const Headers('Withdrawing consent'),
              Hspace(context.height(.015)),
              const Text(
                'Where we are relying on consent to process your personal data you can withdraw your consent at any time. Please note that this will not affect the lawfulness of any processing carried out before you withdraw your consent.',
                textAlign: TextAlign.justify,
              ),
              Hspace(context.height(.02)),
              const Headers('How long we keep your data'),
              Hspace(context.height(.015)),
              const Text(
                'We will only retain your personal data for as long as necessary to fulfil the purposes we collected it for, including for the purposes of satisfying any legal, accounting, or reporting requirements. \n\nTo determine the appropriate retention period for personal data, we consider the amount, nature, and sensitivity of the personal data, the potential risk of harm from unauthorised use or disclosure of your personal data, the purposes for which we process your personal data and whether we can achieve those purposes through other means, and the applicable legal requirements. \n\nWe will normally retain your information for a period of 30 days after your account is deactivated or 30 days after your information is no longer needed to provide you with our services. After this period, the data will be deleted from our systems and we will be unable to access it. In some circumstances you can ask us to delete your data sooner: see Deleting personal data above for further information. If you do wish to cancel your account or request that we no longer use your information to provide you services, please contact us at support@mygaphub.com. \n\nUpon confirmation of becoming an FCA regulated firm, we will have statutory obligations to retain records with respect to the financial services we have provided to you, or introduced to you. Such records will be retained for the shorter of either 12 months beyond the conclusion of the financial service provided, or 5 years. If you cancel your account with us, these statutory records will be archived, and all other information will be deleted. \n\nWhere we anonymise your personal data (i.e. so that it can no longer be associated with you) for further research or statistical purposes, then we may use this information indefinitely without further notice to you.',
                textAlign: TextAlign.justify,
              ),
              Hspace(context.height(.02)),
              const Headers('Security'),
              Hspace(context.height(.015)),
              const Text(
                'Please see our full security policy at https://www.mygaphub.com/security/ \n\nThe security of your personal information is important to us. We follow generally accepted industry standards to protect the personal information submitted to us, both during transmission and once we receive it. No method of transmission over the Internet, or method of electronic storage, is 100% secure, however. Therefore, we cannot guarantee its absolute security.',
                textAlign: TextAlign.justify,
              ),
              Hspace(context.height(.02)),
              const Headers('Links to Other Websites'),
              Hspace(context.height(.015)),
              const Text(
                'Our website may include links to third-party websites, plug-ins and applications. This includes Social Media Features, such as the Facebook Like button and Widgets, the “Share this" button or interactive mini-programs that run on our website. Clicking on those links or enabling those Features may allow third parties to collect or share data about you. For example, these Features may collect your IP address or which page you are visiting on our site, and may set a cookie to enable the Feature to function properly. Social Media Features and Widgets are either hosted by a third party or hosted directly on our Site. We do not control these third-party websites or Features and are not responsible for their privacy statements. Your interactions with these Features are governed by the privacy policy of the company providing it. When you leave one of our websites, we encourage you to read the privacy notice of every website you visit.',
                textAlign: TextAlign.justify,
              ),
              Hspace(context.height(.02)),
              const Headers('Changes to this Privacy Policy'),
              Hspace(context.height(.015)),
              const Text(
                'We may need to modify this privacy policy from time to time, to reflect any key changes in our service or as required by our regulators. \n\nThis version was last updated on 25th June 2021.',
              ),
              Hspace(context.height(.02)),
              const Headers('Changes to your details'),
              Hspace(context.height(.015)),
              const Text(
                'It is important that the personal data we hold about you is accurate and current. Please keep us informed if your personal data changes during your relationship with us. To access and change your personal information, you should log in to your online account on our website and make the necessary changes. The changes will be effective as soon as you save them to your Profile, and a confirmation message will be displayed.',
                textAlign: TextAlign.justify,
              ),
              Hspace(context.height(.02)),
              const Headers('Cookies and Other Tracking Technologies'),
              Hspace(context.height(.015)),
              const Text(
                'What are cookies? \n\nA cookie is a text file containing a small amount of information that is sent to your browser when you visit a website. The cookie is then sent back to the originating website on each subsequent visit, or to another website that recognises it. Cookies are an extremely useful technology and do lots of different jobs. \n\nA Web beacon is an often-transparent graphic image, usually no larger than 1 pixel x 1 pixel, that is placed on a website or in an email that is used to monitor the behaviour of the user visiting the website or sending the email. It is often used in combination with cookies. \n\nWe may collect information through the use of cookies, web beacons or similar analytics-driven technologies.',
              ),
              Hspace(context.height(.02)),
              const Headers('What cookies do we use?'),
              Hspace(context.height(.015)),
              RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: context.width(.037),
                  ),
                  children: const [
                    TextSpan(
                      text: '•	Strictly necessary cookies: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                          'These are cookies that are required for the operation of our website. They include, for example, cookies that enable you to log into secure areas of our website.',
                    ),
                  ],
                ),
              ),
              Hspace(context.height(.015)),
              RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: context.width(.037),
                  ),
                  children: const [
                    TextSpan(
                      text: '•	Analytics/performance cookies: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                          'These types of cookies allow us to recognise and count the number of visitors and to see how visitors move around our website when they are using it. This helps us to improve the way our website works, for example, by ensuring that users can easily find what they are looking for.',
                    ),
                  ],
                ),
              ),
              Hspace(context.height(.015)),
              RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: context.width(.037),
                  ),
                  children: const [
                    TextSpan(
                      text: '•	Functionality cookies: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                          'These are used to recognise you when you return to our website. This enables us to personalise our content for you, greet you by name and remember your preferences.',
                    ),
                  ],
                ),
              ),
              Hspace(context.height(.015)),
              RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: context.width(.037),
                  ),
                  children: const [
                    TextSpan(
                      text: '•	Targeting cookies: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                          'These cookies record your visit to our website, the pages you have visited and the links you have followed. We will use this information to make our website and the advertising displayed on it more relevant to your interests. We may also share this information with third parties for this purpose.',
                    ),
                  ],
                ),
              ),
              Hspace(context.height(.02)),
              const Text(
                'You can find more information about the individual cookies we use and the purposes for which we use them in the table below:',
              ),
              Hspace(context.height(.015)),
              const Table3(),
              Hspace(context.height(.02)),
              const Headers('Important information about cookies'),
              Hspace(context.height(.015)),
              const Text(
                'Please note that third parties (including, for example, advertising networks and providers of external services like web traffic analysis services) may also use cookies, over which we have no control. These cookies are likely to be analytical/performance cookies or targeting cookies.',
              ),
              Hspace(context.height(.02)),
              const Headers('How do I change my cookie settings?'),
              Hspace(context.height(.015)),
              const Text(
                'You block cookies by activating the setting on your browser that allows you to refuse the setting of all or some cookies. However, if you use your browser settings to block all cookies (including essential cookies) you may not be able to access all or parts of our site. \n\nMost web browsers allow some control of most cookies through the browser settings. To find out more about cookies, including how to see what cookies have been set, visit www.aboutcookies.org or www.allaboutcookies.org. \n\nTo find out how to manage cookies on popular browsers:',
              ),
              Hspace(context.height(.015)),
              const Browsers(
                link:
                    'https://support.google.com/accounts/answer/61416?co=GENIE.Platform=Desktop&&hl=en',
                name: 'Google Chrome',
              ),
              Hspace(context.height(.015)),
              const Browsers(
                link:
                    'https://support.microsoft.com/en-us/windows/microsoft-edge-browsing-data-and-privacy-bb8174ba-9d73-dcf2-9b4a-c582b4e640dd',
                name: 'Microsoft Edge',
              ),
              Hspace(context.height(.015)),
              const Browsers(
                link:
                    'https://support.mozilla.org/en-US/kb/enhanced-tracking-protection-firefox-desktop?redirectslug=enable-and-disable-cookies-website-preferences&&redirectlocale=en-US',
                name: 'Mozilla Firefox',
              ),
              Hspace(context.height(.015)),
              const Browsers(
                link:
                    'https://support.microsoft.com/en-us/windows/delete-and-manage-cookies-168dab11-0753-043d-7c16-ede5947fc64d',
                name: 'Microsoft Internet Explorer',
              ),
              Hspace(context.height(.015)),
              const Browsers(
                link: 'https://help.opera.com/en/latest/web-preferences/',
                name: 'Opera',
              ),
              Hspace(context.height(.015)),
              const Browsers(
                link:
                    'https://support.apple.com/en-gb/guide/safari/sfri11471/mac',
                name: 'Apple Safari',
              ),
              Hspace(context.height(.015)),
              const Text(
                'To opt out of being tracked by Google Analytics across all websites, visit http://tools.google.com/dlpage/gaoptout.',
              ),
              Hspace(context.height(.03)),
              Center(
                child: Text(
                  'Last updated: 24th June 2021',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: context.width(.05),
                  ),
                ),
              ),
              Hspace(context.height(.03)),
            ],
          ),
        ),
      ),
    );
  }
}

class Browsers extends StatelessWidget {
  final String name;
  final String link;

  const Browsers({super.key, required this.name, required this.link});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => launch(link),
      child: Text(
        name,
        style: TextStyle(
          decoration: TextDecoration.underline,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}

// style: TextStyle(
//                 fontWeight: FontWeight.bold, fontSize: context.width(.05)),
