export default function updateScheduleDay(){
  if ($(this).is(":checked"))
  {
    $(this).parent().siblings(".hours").show()
    $(this).parent().siblings(".break").show()
  }
  else
  {
    $(this).parent().siblings(".hours").hide()
    $(this).parent().siblings(".break").hide()
  }
}
