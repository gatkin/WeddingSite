using System.Collections.Generic;

namespace WeddingSite.Models
{
    public class GuestsByStatus
    {
        public string Status { get; set; }

        public IEnumerable<string> GuestNames { get; set; }
    }

    public class AttendanceViewModel
    {
        public IEnumerable<GuestsByStatus> GuestsByStatuses { get; set; }
    }
}