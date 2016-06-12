# twitter_1
With this shiny app you can map and analyze responses to tweets from **Donald Trump** and **Hillary Clinotn**.
Furthermore the app calculates the positive oder negative sentiment aggregated on State level.

<a href="https://jonaskr.shinyapps.io/twitter_1/">Click here for a Demo:</a> 

## Description
- The files `ui.r, server.r and global.r` containing the shiny app. 
- The file `fb.r` acceses twitter and follows the offical twitter acounts of Donald Trump and Hillary Clinotn.
  - The tweets inisde the Demo were colectet in the second week in June 
  - `fb.r` uses only tweets which are responses to tweets from Trump or Clinton and have geo location enabled. 
  - For all tweetes the sentiment was calulated, using the `syuzhet` package
  

## Installation 
You will need to collect your own tweets and read them inside `fb.r` as a `.json` object. The output from `fb.r` will be used inide shiny.



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
