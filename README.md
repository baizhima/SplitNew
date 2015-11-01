# Splitter

## Inspiration
There is some embarrassed time when waiter comes to your table with all of you friends having trouble splitting the bill. There are also some restaurants (authentic Chinese probably) that only allow one credit card swipe per table. The card swiper has to spend about 10 minutes to manually figure out who eats which dish listed on the bill. And even though dishes are allocated correctly, it is barely possible to charge each person's tax and tips fairly.

Now it's the time to relax. Introducing our BostonHacks project Splitter! With little effort typing your dishes into this app, every person is able to figure out how much he/she should pay exactly.

## What it does
We support an "one card swiper/multiple members" mechanism. Whenever the card swiper creates a session, each group member will type in the invitation code as key to get into the same group. Each group member only has to type dishes he soloed, and the card swiper needs an extra step to type in all shared dishes and corresponding prices into our App. What's more, we also allow each member to remove those "shared dishes" that he/she did not participated in.

After the card swiper added the tax and tips, he will press the "Split" button at the bottom of screen, and each member will receive their personal bill with tax and tips included.

Here is a link of our high-resolution Splitter diagram: [link](http://baizhima.github.io/documents/hackbu/diagram.jpg)

## How I built it
Our application is backed by Parse. This BaaS service saves us tons of time writing a backend server for this application, and we developers can put most of our time designing data models and decorating user interfaces.



## Challenges I ran into
As junior iOS developers, our team has only limited knowledge in Cocoa Touch classes and Swift syntax. We think the hardest part to fully understand is Auto-Layout. After some struggled time finding online resources, our team finally decided not to support all sized iPhones in this alpha version release.


## Accomplishments that I'm proud of
Applied what I learned from Database and Computer Network courses into real projects. Server-client intercommunication, non-blocking I/O, E-R database design pattern and even more...


## What I learned
**Trust your teammates**. Our team is formed by 2 Brown Computer Science graduate students as developers and 1 RISD grad student as main designer. As a team of three, all of us have to shoulder much more than our given title. Our designer not only drafted all views user interfaces but also gave useful suggestion on the whole application logic.


## What's next for Splitter
We've already added Venmo icon at the payment detail view, indicating that in the next iteration we will support making payments through Venmo's iOS SDK.

## How to run
* Download from your terminal: git clone https://github.com/baizhima/SplitNew.git
* Open SplitMe.xcodeproj with your xcode (if there're any problems when you are building the project, please first update to the newest Xcode and iOS SDK)
* Build the project into build your iPhone. This app works best for 4.7 inches iPhone 6(s).

