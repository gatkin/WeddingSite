using System.Collections.Generic;

namespace WeddingSite.Models
{
    public class AttendanceRequest
    {
        public IEnumerable<int> GuestIds { get; set; }

        public bool IsAttending { get; set; }
    }
}