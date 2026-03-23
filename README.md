**GISP - Data as an Asset**
A web application prototype https://gisp.kambox.ru/ demonstrating the functionality and user UX in the process of automated calculation of recommended support measures.

As an example, the prototype implements a demonstration of ranking available support measures for a new user. To obtain a convenient ranked list of support measures, the user simply needs to specify their region and industry.
After providing these two parameters, the user is presented with a compact list of support measures ranked by a Rating score, along with information on the detailed ranking criteria.
For a registered user, the rating-ranked list of available support measures can be provided immediately upon login, since both primary filtering parameters are already available in the user's profile (region and industry are required during registration).

**Further development**
Development of a machine learning model that takes contextual key phrases into account:
1. Developing a list of principal keywords suitable for ranking support measures
2. Forming 10–15 keyword sets for advertising campaigns
3. Computing a recommendation rating for each keyword
