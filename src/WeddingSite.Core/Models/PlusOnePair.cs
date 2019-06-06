namespace WeddingSite.Core
{
    public class PlusOnePair
    {
        public string PartnerAId { get; set; }

        public string PartnerBId { get; set; }

        public PlusOnePair(string aId, string bId)
        {
            PartnerAId = aId;
            PartnerBId = bId;
        }
    }
}