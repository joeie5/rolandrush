import React from 'react';
import {
  Bar,
  BarChart,
  CartesianGrid,
  Line,
  LineChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis } from
'recharts';
import { ordersPerDay, supplyTrend } from '../../data/phaseTwo';
import { serviceZones } from '../../data/config';
import { PageHeader } from '../../components/ui/PageHeader';
import { Panel, PanelHeader } from '../../components/ui/Panel';
import {
  Table,
  TBody,
  TD,
  TH,
  THead,
  TR } from
'../../components/ui/Table';
import { Select } from '../../components/ui/Field';
import { naira } from '../../utils/format';

const AXIS = { stroke: '#98989A', fontSize: 11 };

export function Analytics() {
  const [range, setRange] = React.useState('7d');

  return (
    <>
      <PageHeader
        title="Platform analytics"
        phaseTwo
        subtitle="Order volume, GMV and supply growth. Enough to answer “is the platform growing and where”, not a full BI tool."
        actions={
        <Select
          className="w-[170px]"
          label="Range"
          value={range}
          onChange={setRange}
          options={[
          { value: '7d', label: 'Last 7 days' },
          { value: '30d', label: 'Last 30 days' },
          { value: '90d', label: 'Last 90 days' }]
          } />

        } />
      

      <div className="mb-4 grid grid-cols-2 gap-px overflow-hidden rounded-xl border border-line bg-line lg:grid-cols-5">
        {[
        { label: 'Orders (7d)', value: '5,186', sub: '+11% w/w' },
        { label: 'GMV (7d)', value: naira(51100000, { compact: true }), sub: '+9% w/w' },
        { label: 'Avg basket', value: naira(9850), sub: '−2% w/w' },
        { label: 'Active vendors', value: '190', sub: '+8 this week' },
        { label: 'Active riders', value: '97', sub: '+4 this week' }].
        map((stat) =>
        <div key={stat.label} className="bg-surface px-4 py-3">
            <p className="text-xs text-ink-muted">{stat.label}</p>
            <p className="tabular mt-0.5 text-lg font-semibold text-ink">
              {stat.value}
            </p>
            <p className="text-2xs text-ink-faint">{stat.sub}</p>
          </div>
        )}
      </div>

      <div className="grid grid-cols-12 gap-4">
        <Panel className="col-span-12 xl:col-span-7">
          <PanelHeader title="Orders per day" meta="Last 7 days, all zones" />
          <div className="h-[240px] px-2 py-4">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={ordersPerDay}>
                <CartesianGrid stroke="#F1F1F2" vertical={false} />
                <XAxis dataKey="day" tickLine={false} axisLine={false} tick={AXIS} />
                <YAxis tickLine={false} axisLine={false} tick={AXIS} width={40} />
                <Tooltip
                  contentStyle={{
                    borderRadius: 10,
                    border: '1px solid #E7E7E8',
                    fontSize: 13
                  }} />
                
                <Bar dataKey="orders" fill="#FF3B4E" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </Panel>

        <Panel className="col-span-12 xl:col-span-5">
          <PanelHeader title="Supply growth" meta="Active vendors and riders by week" />
          <div className="h-[240px] px-2 py-4">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={supplyTrend}>
                <CartesianGrid stroke="#F1F1F2" vertical={false} />
                <XAxis dataKey="week" tickLine={false} axisLine={false} tick={AXIS} />
                <YAxis tickLine={false} axisLine={false} tick={AXIS} width={40} />
                <Tooltip
                  contentStyle={{
                    borderRadius: 10,
                    border: '1px solid #E7E7E8',
                    fontSize: 13
                  }} />
                
                <Line
                  type="monotone"
                  dataKey="vendors"
                  stroke="#1A1A1A"
                  strokeWidth={2}
                  dot={false} />
                
                <Line
                  type="monotone"
                  dataKey="riders"
                  stroke="#FF3B4E"
                  strokeWidth={2}
                  dot={false} />
                
              </LineChart>
            </ResponsiveContainer>
          </div>
        </Panel>

        <Panel className="col-span-12">
          <PanelHeader title="Zone performance" meta="Last 7 days" />
          <Table>
            <THead>
              <TH>Zone</TH>
              <TH align="right">Orders</TH>
              <TH align="right">Vendors</TH>
              <TH align="right">Riders</TH>
              <TH align="right">Orders per rider</TH>
              <TH align="right">Base fee</TH>
            </THead>
            <TBody>
              {serviceZones.
              filter((zone) => zone.status !== 'planned').
              sort((a, b) => b.orders7d - a.orders7d).
              map((zone) =>
              <TR key={zone.id}>
                    <TD className="font-medium text-ink">{zone.name}</TD>
                    <TD align="right" className="tabular">
                      {zone.orders7d.toLocaleString('en-NG')}
                    </TD>
                    <TD align="right" className="tabular">
                      {zone.vendors}
                    </TD>
                    <TD align="right" className="tabular">
                      {zone.riders}
                    </TD>
                    <TD align="right" className="tabular">
                      {zone.riders ? Math.round(zone.orders7d / zone.riders) : '—'}
                    </TD>
                    <TD align="right" className="tabular">
                      {naira(zone.baseFee)}
                    </TD>
                  </TR>
              )}
            </TBody>
          </Table>
        </Panel>
      </div>
    </>);

}