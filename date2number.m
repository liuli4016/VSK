function datevalue=date2number(month,day,hour)

switch month
    case 1,
        m=0;
    case 2,
        m=24*31;
    case 3,
        m=24*59;
    case 4,
        m=24*90;
    case 5,
        m=24*120;
    case 6,
        m=24*151;
    case 7,
        m=24*181;
    case 8,
        m=24*212;
    case 9,
        m=24*243;
    case 10,
        m=24*273;
    case 11,
        m=24*304;
    case 12,
        m=24*334;
end

%d=24*(day-1);
d=24*day;

datevalue=m+d+hour;
