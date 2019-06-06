using System.Collections.Generic;

namespace WeddingSite.Models
{
    public class AttendanceRequest
    {
        public IEnumerable<string> GuestIds { get; set; }

        public bool IsAttending { get; set; }
    }
}