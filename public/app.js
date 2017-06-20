$facebook_buttons = $('.shares .btn-facebook')
$twitter_buttons = $('.shares .btn-twitter')
$download_buttons = $('.shares .btn-download')

$('.slider-dots button').on('click', function(){
  console.log($(this).text());
  $facebook_buttons.attr(
    'href',
    "https://www.facebook.com/sharer/sharer.php?u=http://faces.comingout.space/face/" + window.userID + '/' + $(this).text()
  )
  $facebook_buttons.attr(
    'share-url',
    'http://faces.comingout.space/face/' + window.userID + '/' + $(this).text()
  )
  $twitter_buttons.attr(
    'href',
    'http://' + encodeURI('www.twitshot.com/?url=http://faces.comingout.space/&text=Happy coming out day!&image=http://faces.comingout.space/image/'+ window.userID + '/' + $(this).text() + '&count=true&hide=true')
  )
  $download_buttons.attr(
    'href',
    'http://faces.comingout.space/image/' + window.userID + '/' + $(this).text()
  )
})

$('.btn-facebook').on('click', function(e){
  e.preventDefault();
  FB.ui({
    method: 'share',
    href: $(this).attr('share-url'),
  }, function(response){});
})
