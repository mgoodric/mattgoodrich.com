---
title:  "Breaking into security"
categories: 
  - Security
tags:
  - career
---

Over the years, I have been asked the question "How do I break into the security field?" many times. Up until recently, I have always had the opinion that I am the worst person to ask as I fell into the field by accident. Now that a decade has passed since my accidental entry into the field, and I have had the opportunity to work across the different security domains and build teams of security folks for various purposes - I have found that I do have some perspective worth sharing.

I suppose I should warn you that the items I outline below are not specific to any security domain (and I don’t want to start yet another flame war around if people working in security should know how to code) but are instead the top things I tend to look for when hiring and that I consider for my own next role.

## Passion

The number one trait I look for in the people I choose to work with is passion. No, this doesn’t mean you need to self-fund your attendance to a SANS course or spend every waking moment pwning boxes on Hack the Box (unless you love it—you do you). To me, passion is a lasting excitement about something that may give you purpose, something you want to learn more about and improve on. I can tell you early in my career I did not have a passion for security. I had a sweet job that paid well and allowed me to travel all over the US as an Identity and Access Management consultant. It came easy to me and provided a lifestyle I enjoyed, but I wasn’t driven by passion. Over the last decade, I have found that what truly excites me is the technical side of security: security architecture, application security, cloud security, etc. My podcast library is full of either security related shows, or aviation related shows - my professional and personal passions on display. 

Passion is certainly something that grows and changes over time, but in my experience, it’s hard to fake. Within minutes of interviewing someone, I can typically tell if they are passionate about security. For Christmas this year I got a shirt that says "Warning: May spontaneously talk about airplanes" - which is absolutely a true warning, but I feel like if you could replace "airplanes" with anything the wearer of the shirt has a passion for and it would be just as valid. And that passion, that constant drive to share, learn more, and develop it further—that’s what helps an individual and a team thrive long-term.

## Empathy for other teams

Security is a big space: governance, risk, compliance, security architecture, security operations, penetration testing, physical security, cloud security, application security…this list goes on. Much of the work a traditional Information Security team does involves identifying and remediating risks within the organization. And as we all know, everybody wants things done now, and everything is a top priority.

Truly understanding what it will take to complete a piece of work, and the balance of work that exists on someone’s plate, is crucial for security teams to have a positive impact. Yes, of course, as a security professional you likely believe that security is the top priority…but, I can tell you that outside of the security team, it’s usually not. Have you ever had to patch hundreds, or even thousands, of systems that are out of date? That’s not an easy task. Have you been given a list of hundreds or thousands of vulnerabilities that an automated tool found in your code and been asked to fix them "ASAP"? Do you know how long it will take to fix each vulnerability found? It’s never as easy as you would expect, and there are often other forces that add complexity or risk. One of those unpatched machines may have software running on it that is critical to the organization, and the latest round of patches could render the application useless. There could be mitigating controls in place already that provide more protection than the patch would. Changing how code was written due to a static analysis could violate internal development standards, or the analysis could have missed where you were doing the proper escaping outside of the current file. 

CISOs are often tasked with improving the security posture of an organization, and many I have worked with rely on metrics available to them from their tools. When using this manage-by-numbers approach, it's easy to lose sight of the impact that introducing unscheduled or non-feature work has on existing business priorities. Additionally, disciplines like Application Security, though they may seem deeply technical in nature, require a foundation of trust and connection with their engineering peers. Trust is eroded when you have a mandate to come in like a wrecking ball and upset a roadmap of planned work with a long list of issues that are likely hard or impossible to exploit - all so that the CISO and the board can sleep well at night thinking they are safe. Security personnel from the lowest levels all the way to the C-Level would be better served by having empathy for their teams and the teams they are impacting.

To me, security professionals who have moved into the space over the course of their career have a greater degree of empathy because they've lived the experiences of other teams and understand their motivations and challenges. That doesn't mean career security professionals can't develop that same empathy over time, it just requires more conscious effort on their part.
 
## Understanding of business priorities

During my time in the security field, I have come to realize that security people tend to fall into two buckets:
1.	Those who believe security should be absolute – the smallest possible attack surface across all vectors.
2.	Those who acknowledge that nothing will ever be 100% secure and focus on the business context in balance with security best practices 

In my opinion, those that align more closely to bucket #2 are the ones who are the most successful in the security world. While perhaps unsettling, it’s only realistic to acknowledge that there will always be gaps in protection, new exploits, and varying customer priorities that challenge your security philosophy. One of the leaders in Alteryx’s product organization whom I highly respect sent me the below during a recent discussion about customer feedback.

> "Your opinion, while interesting, is irrelevant."

When building a product, internal opinions about what should be built are irrelevant - *Innovators Dilemma* be damned, current and prospective customers always tend to have a lot to say about a product - and security is not free from customer influence. If you follow the bucket #1 philosophy, it becomes harder to cater to things like customer influence or even regulatory differences. Does an organization that doesn't cater to a healthcare audience need to build its protocol around HIPAA? And if it does, could it be at the detriment of user experience and thus customer satisfaction and retention? Following the absolute mindset doesn't allow for the nuance needed to best serve your customers in your specific segment.

Now I do believe that security should be baked in from the beginning and enabled by default. I think projects like the OWASP Application Security Verification Standard (ASVS) are a great set of requirements that should be present across all software. However, security features that go beyond table stakes should be vetted with current and prospective customers, or should have a revenue driver associated with them (either a potential loss, or unrealized gain). There is no reason to attempt to boil the ocean with security.

One unifying characteristic of passion, empathy, and business acumen? They’re hard to identify in a resume (though it can be argued that the latter two are dependent on some modicum of experience). When you’re fortunate enough to interview a candidate who can convey all three, though, don’t let them pass you by. I have found that those security professionals who are passionate and willing to learn are unstoppable. And while I haven’t directly answered the question of how to break into security with a clear roadmap, I hope understanding the soft skills that make you an attractive and successful candidate can help you plan your path. 

-G$