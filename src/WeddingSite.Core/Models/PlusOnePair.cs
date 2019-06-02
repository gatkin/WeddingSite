namespace WeddingSite.Core
{
    public class PlusOnePair
    {
        public int PartnerAId { get; set; }

        public int PartnerBId { get; set; }

        public PlusOnePair(int aId, int bId)
        {
            PartnerAId = aId;
            PartnerBId = bId;
        }
    }
}