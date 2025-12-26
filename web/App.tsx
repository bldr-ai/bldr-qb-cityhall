import { useState, useEffect } from 'react';
import { useNuiEvent, fetchNui } from './hooks/useNui';
import { X, FileText, Briefcase, Home, ArrowRight } from 'lucide-react';

interface License {
  id: string;
  label: string;
  price: number;
  description: string;
}

interface Job {
  id: string;
  label: string;
  description: string;
}

type Screen = 'welcome' | 'licenses' | 'jobs';

export default function App(): JSX.Element {
  const isDebug = typeof (window as any).GetParentResourceName !== 'function';
  const [visible, setVisible] = useState(isDebug);
  const [screen, setScreen] = useState<Screen>('welcome');
  const [licenses, setLicenses] = useState<License[]>([]);
  const [jobs, setJobs] = useState<Job[]>([]);
  const [loading, setLoading] = useState<string | null>(null);
  const [hallIndex, setHallIndex] = useState(1);

  useNuiEvent('open', (data: { licenses?: License[]; jobs?: Job[]; hallIndex?: number }) => {
    setLicenses(data.licenses || []);
    setJobs(data.jobs || []);
    setHallIndex(data.hallIndex || 1);
    setVisible(true);
    setScreen('welcome');
  });

  useNuiEvent('close', () => {
    setVisible(false);
  });

  const handleClose = async () => {
    await fetchNui('close');
  };

  const handlePurchaseLicense = async (license: License) => {
    setLoading(license.id);
    try {
      await fetchNui('purchaseLicense', { license: license.id, hallIndex });
    } catch (error) {
      console.error('Failed to purchase license:', error);
    } finally {
      setLoading(null);
    }
  };

  const handleApplyJob = async (job: Job) => {
    setLoading(job.id);
    try {
      await fetchNui('applyJob', { job: job.id, hallIndex });
    } catch (error) {
      console.error('Failed to apply for job:', error);
    } finally {
      setLoading(null);
    }
  };

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape' && visible) {
        handleClose();
      }
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [visible]);

  if (!visible) return <></>;

  return (
    <div className="fixed inset-0 bg-black/40 flex items-center justify-center font-sans">
      <div className="w-[90vw] max-w-4xl h-[85vh] bg-gradient-to-br from-slate-900 via-slate-800 to-slate-900 rounded-xl shadow-2xl border border-slate-700 flex flex-col overflow-hidden">
        
        {/* Header */}
        <div className="bg-gradient-to-r from-red-600 to-red-700 px-8 py-6 flex items-center justify-between border-b border-red-800">
          <h1 className="text-3xl font-bold text-white tracking-wider">CITY HALL SERVICES</h1>
          <button
            onClick={handleClose}
            className="p-2 hover:bg-red-800 rounded-lg transition-colors"
          >
            <X className="w-6 h-6 text-white" />
          </button>
        </div>

        {/* Navigation Bar */}
        {screen !== 'welcome' && (
          <div className="bg-slate-800/50 px-8 py-4 flex items-center justify-between border-b border-slate-700">
            <div className="flex items-center gap-2">
              <button
                onClick={() => setScreen('welcome')}
                className="text-slate-400 hover:text-red-400 transition-colors flex items-center gap-1 font-semibold"
              >
                <Home className="w-4 h-4" />
                Home
              </button>
              <span className="text-slate-600">/</span>
              <span className="text-slate-300 font-semibold">
                {screen === 'licenses' ? 'Civilian Services' : 'Public Jobs'}
              </span>
            </div>
            <button
              onClick={() => setScreen('welcome')}
              className="px-4 py-2 bg-red-600 hover:bg-red-700 text-white rounded-lg font-semibold transition-colors"
            >
              ← Back
            </button>
          </div>
        )}

        {/* Content */}
        <div className="flex-1 overflow-y-auto p-8">
          {screen === 'welcome' ? (
            <div className="h-full flex flex-col items-center justify-center">
              <div className="text-center mb-12">
                <h2 className="text-5xl font-bold text-white mb-4">Welcome to City Hall</h2>
                <p className="text-slate-400 text-lg">Select what you'd like to do today</p>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-8 w-full max-w-2xl">
                {/* Civilian Services Card */}
                <button
                  onClick={() => setScreen('licenses')}
                  className="group bg-gradient-to-br from-slate-700 to-slate-800 rounded-xl p-8 border border-slate-600 hover:border-red-600 transition-all hover:shadow-2xl hover:shadow-red-600/30 cursor-pointer text-left"
                >
                  <div className="flex items-start justify-between mb-4">
                    <div className="bg-red-600/20 p-4 rounded-lg group-hover:bg-red-600/30 transition-colors">
                      <FileText className="w-8 h-8 text-red-400" />
                    </div>
                    <ArrowRight className="w-6 h-6 text-slate-600 group-hover:text-red-400 transition-colors translate-x-0 group-hover:translate-x-1" />
                  </div>
                  <h3 className="text-2xl font-bold text-white mb-2">Civilian Services</h3>
                  <p className="text-slate-400">
                    Request and purchase official documents including driver licenses, ID cards, and weapon permits.
                  </p>
                </button>

                {/* Public Jobs Card */}
                <button
                  onClick={() => setScreen('jobs')}
                  className="group bg-gradient-to-br from-slate-700 to-slate-800 rounded-xl p-8 border border-slate-600 hover:border-red-600 transition-all hover:shadow-2xl hover:shadow-red-600/30 cursor-pointer text-left"
                >
                  <div className="flex items-start justify-between mb-4">
                    <div className="bg-red-600/20 p-4 rounded-lg group-hover:bg-red-600/30 transition-colors">
                      <Briefcase className="w-8 h-8 text-red-400" />
                    </div>
                    <ArrowRight className="w-6 h-6 text-slate-600 group-hover:text-red-400 transition-colors translate-x-0 group-hover:translate-x-1" />
                  </div>
                  <h3 className="text-2xl font-bold text-white mb-2">Public Jobs</h3>
                  <p className="text-slate-400">
                    Apply for public sector employment opportunities across the city.
                  </p>
                </button>
              </div>
            </div>
          ) : screen === 'licenses' ? (
            <div className="w-full">
              <h2 className="text-3xl font-bold text-white mb-8">Civilian Services</h2>
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {licenses.length > 0 ? (
                  licenses.map((license) => (
                    <div
                      key={license.id}
                      className="bg-gradient-to-br from-slate-700 to-slate-800 rounded-lg p-6 border border-slate-600 hover:border-red-600 transition-all hover:shadow-xl hover:shadow-red-600/20 group"
                    >
                      <div className="flex items-start justify-between mb-4">
                        <div className="flex-1">
                          <h3 className="text-xl font-bold text-white group-hover:text-red-400 transition-colors">
                            {license.label}
                          </h3>
                          <p className="text-slate-400 text-sm mt-1">{license.description}</p>
                        </div>
                      </div>

                      <div className="mt-6 pt-4 border-t border-slate-600 flex items-center justify-between">
                        <span className="text-2xl font-bold text-green-400">${license.price}</span>
                        <button
                          onClick={() => handlePurchaseLicense(license)}
                          disabled={loading === license.id}
                          className={`px-6 py-2 rounded-lg font-semibold transition-all ${
                            loading === license.id
                              ? 'bg-slate-600 text-slate-400 cursor-not-allowed'
                              : 'bg-red-600 text-white hover:bg-red-700 active:scale-95'
                          }`}
                        >
                          {loading === license.id ? 'Processing...' : 'Purchase'}
                        </button>
                      </div>
                    </div>
                  ))
                ) : (
                  <div className="col-span-full text-center py-12">
                    <p className="text-slate-400 text-lg">No licenses available</p>
                  </div>
                )}
              </div>
            </div>
          ) : (
            <div className="w-full">
              <h2 className="text-3xl font-bold text-white mb-8">Public Jobs</h2>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                {jobs.length > 0 ? (
                  jobs.map((job) => (
                    <div
                      key={job.id}
                      className="bg-gradient-to-br from-slate-700 to-slate-800 rounded-lg p-6 border border-slate-600 hover:border-red-600 transition-all hover:shadow-xl hover:shadow-red-600/20 group"
                    >
                      <div className="flex items-start justify-between mb-4">
                        <div className="flex-1">
                          <h3 className="text-xl font-bold text-white group-hover:text-red-400 transition-colors">
                            {job.label}
                          </h3>
                          <p className="text-slate-400 text-sm mt-1">{job.description}</p>
                        </div>
                      </div>

                      <div className="mt-6 pt-4 border-t border-slate-600">
                        <button
                          onClick={() => handleApplyJob(job)}
                          disabled={loading === job.id}
                          className={`w-full px-6 py-3 rounded-lg font-semibold transition-all ${
                            loading === job.id
                              ? 'bg-slate-600 text-slate-400 cursor-not-allowed'
                              : 'bg-red-600 text-white hover:bg-red-700 active:scale-95'
                          }`}
                        >
                          {loading === job.id ? 'Processing...' : 'Apply Now'}
                        </button>
                      </div>
                    </div>
                  ))
                ) : (
                  <div className="col-span-full text-center py-12">
                    <p className="text-slate-400 text-lg">No jobs available</p>
                  </div>
                )}
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
