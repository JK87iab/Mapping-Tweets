# Mapping-Tweets 
With this shiny app you can map and analyze responses to tweets from **Donald Trump** and **Hillary Clinton**. Furthermore the data tool calculates the positive or negative sentiment aggregated at State level.

<a href="https://jonaskr.shinyapps.io/twitter_1/">Click here for a Demo:</a> 

## Description
- The files `ui.r, server.r and global.r` containing the shiny app. 
- The file `fb.r` access twitter and follows the official twitter accounts of Donald Trump and Hillary Clinton.
  - The tweets for the Demo were collected in the second week in June.
  - `fb.r` uses only tweets which are responses to tweets from Trump or Clinton and have geo location enabled. 
  - For all tweets the sentiment was calculated using the `syuzhet` package
  

## Installation 
You will need to collect your own tweets and read them inside `fb.r` as a `.json` object. The output from `fb.r` will be used inside shiny.

## To Do
As of now the sentiment is calculated counting positive/negative keywords using the NRC Word-Emotion Association Lexicon. This works in a lot of settings but it is not well suited to detect irony. 
Furthermore, I am only able to classify the tweet in positive or negative, not if the tweet agrees with the candidate. E.g. a negative answer to a negative tweet could be seen that the user agrees and reinforces the negative tweet of the author
Further development could use labeled tweets and leverage machine learning algorithm to classify tweets in positive/ negative. RTextTools delivers a lot of functionality and would improve the overall accuracy of the classification. 


## Credits
-Crowdsourcing a Word-Emotion Association Lexicon, Saif Mohammad and Peter Turney, To Appear in Computational Intelligence, Wiley Blackwell Publishing Ltd.

Free Public License 1.0.0

Permission to use, copy, modify, and/or distribute this software for
any purpose with or without fee is hereby granted.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES
OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE
FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY
DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN
AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT
OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
