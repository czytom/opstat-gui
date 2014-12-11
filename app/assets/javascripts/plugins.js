// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(document).ready(function() {
  $('#reportrange').daterangepicker({ timePicker: true, timePicker12Hour: false, timePickerIncrement: 5, format: 'YYYY-MM-DD H:mm',ranges: {
         'Last hour': [moment().subtract('hours',1), moment()],
         'Last 6 hours': [moment().subtract('hours',6), moment()],
         'Today': [moment().startOf('day'), moment()],
         'Yesterday': [moment().subtract('days', 1), moment().subtract('days', 1)],
         'Last 7 Days': [moment().subtract('days', 6), moment()],
         'Last 30 Days': [moment().subtract('days', 29), moment()],
         'This Month': [moment().startOf('month'), moment().endOf('month')],
         'Last Month': [moment().subtract('month', 1).startOf('month'), moment().subtract('month', 1).endOf('month')]
      },
      startDate: moment().subtract('days', 29),
      endDate: moment()
    },
    function(start, end) {
        $('#reportrange input #plugin_period').html(start.format('MMMM D, YYYY') + ' - ' + end.format('MMMM D, YYYY'));
	document.getElementById('plugin_date_range_start').value=start.toJSON();
	document.getElementById('plugin_date_range_end').value=end.toJSON();
$('#date_range_form').submit();
    }
);
});
