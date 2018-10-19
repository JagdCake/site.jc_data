// Source: https://stackoverflow.com/a/2627493/8980616
function getTotalDays() { 
    const oneDayMs = 24*60*60*1000;
    const dateStart = new Date('2016-06-01');
    const dateLastUpdate = new Date('date_last_update');

    const dateStartMs = dateStart.getTime();
    const dateLastUpdateMs = dateLastUpdate.getTime();

    const totalDays = Math.round(Math.abs((dateStartMs - dateLastUpdateMs) / (oneDayMs)));

    return totalDays;
}
