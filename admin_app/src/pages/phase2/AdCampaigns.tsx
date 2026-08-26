import React from 'react';
import { CheckIcon, MegaphoneIcon, XIcon } from 'lucide-react';
import { adCampaigns } from '../../data/phaseTwo';
import { PageHeader } from '../../components/ui/PageHeader';
import {
  Table,
  TBody,
  TD,
  TH,
  THead,
  TR,
  TableShell } from
'../../components/ui/Table';
import { StatusBadge, TierBadge } from '../../components/ui/Badge';
import { Button } from '../../components/ui/Button';
import { EmptyState } from '../../components/ui/Pagination';
import { DecisionDialog, useDecision } from '../../components/ui/DecisionDialog';
import { useAdmin } from '../../contexts/AdminContext';
import { ago, naira } from '../../utils/format';
import { TIER_META } from '../../utils/tiers';
import type { AdCampaign } from '../../types';

export function AdCampaigns() {
  const { logAction } = useAdmin();
  const decision = useDecision();
  const [campaigns, setCampaigns] = React.useState<AdCampaign[]>(adCampaigns);

  const decide = (campaign: AdCampaign, intent: 'approve' | 'reject') =>
  decision.ask({
    title:
    intent === 'approve' ?
    `Run “${campaign.title}”?` :
    `Reject “${campaign.title}”?`,
    consequence:
    intent === 'approve' ?
    'The campaign starts serving immediately and the vendor’s budget begins to spend.' :
    'The vendor is refunded their budget and notified with your reason.',
    facts: [
    { label: 'Vendor', value: campaign.vendor },
    { label: 'Budget', value: naira(campaign.budget) }],

    intent,
    reasonRequired: intent === 'reject' || campaign.tier === 'urgent',
    reasonLabel: 'Reason',
    suggestions: [
    'Creative promises a price that does not exist on the menu.',
    'Claim cannot be substantiated.'],

    confirmLabel: intent === 'approve' ? 'Approve campaign' : 'Reject campaign',
    onConfirm: (reason) => {
      setCampaigns((current) =>
      current.map((item) =>
      item.id === campaign.id ?
      { ...item, status: intent === 'approve' ? 'running' : 'rejected' } :
      item
      )
      );
      logAction({
        area: 'moderation',
        sentence: `${intent === 'approve' ? 'approved' : 'rejected'} the “${campaign.title}” ad campaign for ${campaign.vendor}`,
        reason: reason || undefined,
        outcome: intent === 'approve' ? 'ok' : 'urgent'
      });
    }
  });

  const pending = campaigns.filter((campaign) => campaign.status === 'pending');

  return (
    <>
      <PageHeader
        title="Ad campaigns"
        phaseTwo
        subtitle={`${pending.length} campaigns waiting for approval. Creative claims get checked against the vendor’s live menu before anything serves.`} />
      

      <TableShell>
        {campaigns.length === 0 ?
        <EmptyState icon={MegaphoneIcon} title="No campaigns" /> :

        <Table>
            <THead>
              <TH>Campaign</TH>
              <TH>Vendor</TH>
              <TH>Routing</TH>
              <TH align="right">Budget</TH>
              <TH align="right">Spend</TH>
              <TH align="right">Impressions</TH>
              <TH align="right">CTR</TH>
              <TH>Submitted</TH>
              <TH>Status</TH>
              <TH align="right" width="150px" />
            </THead>
            <TBody>
              {campaigns.map((campaign) =>
            <TR key={campaign.id} className={TIER_META[campaign.tier].rail}>
                  <TD className="font-medium text-ink">{campaign.title}</TD>
                  <TD>{campaign.vendor}</TD>
                  <TD>
                    <TierBadge tier={campaign.tier} />
                  </TD>
                  <TD align="right" className="tabular">
                    {naira(campaign.budget)}
                  </TD>
                  <TD align="right" className="tabular">
                    {campaign.spend ? naira(campaign.spend) : '—'}
                  </TD>
                  <TD align="right" className="tabular">
                    {campaign.impressions ?
                campaign.impressions.toLocaleString('en-NG') :
                '—'}
                  </TD>
                  <TD align="right" className="tabular">
                    {campaign.impressions ?
                `${(campaign.clicks / campaign.impressions * 100).toFixed(1)}%` :
                '—'}
                  </TD>
                  <TD className="text-sm">{ago(campaign.submittedAt)}</TD>
                  <TD>
                    <StatusBadge status={campaign.status} />
                  </TD>
                  <TD align="right">
                    {campaign.status === 'pending' ?
                <div className="flex justify-end gap-1.5">
                        <Button
                    size="sm"
                    variant="approve"
                    icon={CheckIcon}
                    onClick={() => decide(campaign, 'approve')}>
                    
                          Run
                        </Button>
                        <Button
                    size="sm"
                    variant="danger"
                    icon={XIcon}
                    onClick={() => decide(campaign, 'reject')}>
                    
                          Reject
                        </Button>
                      </div> :
                null}
                  </TD>
                </TR>
            )}
            </TBody>
          </Table>
        }
      </TableShell>

      <DecisionDialog request={decision.request} onClose={decision.close} />
    </>);

}