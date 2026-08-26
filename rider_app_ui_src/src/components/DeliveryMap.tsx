import React from 'react';
import { CircleMarker, MapContainer, Polyline, TileLayer, Tooltip } from 'react-leaflet';
import type { Job } from '../types';

interface DeliveryMapProps {
  job: Job;
  step: number;
}

export function DeliveryMap({ job, step }: DeliveryMapProps) {
  const pickup: [number, number] = [job.pickupLat, job.pickupLng];
  const dropoff: [number, number] = [job.dropoffLat, job.dropoffLng];
  const rider: [number, number] =
  step <= 1 ?
  [job.pickupLat + 0.006, job.pickupLng - 0.005] :
  [(job.pickupLat + job.dropoffLat) / 2, (job.pickupLng + job.dropoffLng) / 2];
  const center: [number, number] = [
  (job.pickupLat + job.dropoffLat) / 2,
  (job.pickupLng + job.dropoffLng) / 2];

  const legActive = step <= 1;

  return (
    <MapContainer
      center={center}
      zoom={14}
      zoomControl={false}
      attributionControl
      className="h-full w-full"
      style={{ height: '100%', width: '100%' }}>
      
      <TileLayer
        url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        attribution="&copy; OpenStreetMap" />
      
      <Polyline
        positions={legActive ? [rider, pickup] : [rider, dropoff]}
        pathOptions={{ color: '#FF3B4E', weight: 6, opacity: 0.95, lineCap: 'round' }} />
      
      <Polyline
        positions={legActive ? [pickup, dropoff] : [pickup, rider]}
        pathOptions={{ color: '#1A1A1A', weight: 4, opacity: 0.25, dashArray: '2 10', lineCap: 'round' }} />
      
      <CircleMarker
        center={pickup}
        radius={11}
        pathOptions={{ color: '#FFFFFF', weight: 3, fillColor: '#F79009', fillOpacity: 1 }}>
        
        <Tooltip direction="top" offset={[0, -10]} opacity={1}>
          {job.restaurant}
        </Tooltip>
      </CircleMarker>
      <CircleMarker
        center={dropoff}
        radius={11}
        pathOptions={{ color: '#FFFFFF', weight: 3, fillColor: '#12B76A', fillOpacity: 1 }}>
        
        <Tooltip direction="top" offset={[0, -10]} opacity={1}>
          {job.dropoffArea}
        </Tooltip>
      </CircleMarker>
      <CircleMarker
        center={rider}
        radius={13}
        pathOptions={{ color: '#FFFFFF', weight: 4, fillColor: '#1A1A1A', fillOpacity: 1 }} />
      
    </MapContainer>);

}